#!/usr/bin/env bash
# Confere, de fora, uma VPS em que o instalador já rodou. Não muda nada na VPS (só o --reiniciar reinicia).
# Uso: testes/conferir-vps.sh <ip> <chave-ssh> [--reiniciar]
# Antes, na VPS nova (Ubuntu 24.04), pelo Console web da Hostinger (root):
#   curl -fsSL "https://redpro.com.br/instalar?k=CHAVE" -o configurar-vps.sh && bash configurar-vps.sh   (CHAVE: página /configurar-vps)
set -uo pipefail
IP="${1:?ip}"; CHAVE="${2:?chave ssh}"; REINICIAR="${3:-}"
SSHO=(-o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -o BatchMode=yes)
ok=0; falha=0
passa() { printf '  ✔ %s\n' "$1"; ok=$((ok + 1)); }
cai()   { printf '  ✖ %s\n' "$1"; falha=$((falha + 1)); }
h() { ssh "${SSHO[@]}" -i "$CHAVE" "hermes@$IP" "$@"; }
confere() { local rot="$1"; shift; if "$@" >/dev/null 2>&1; then passa "$rot"; else cai "$rot"; fi; }

echo "== Acesso"
confere "entra como hermes com a chave" h true
if ssh "${SSHO[@]}" -i "$CHAVE" "root@$IP" true 2>/dev/null; then cai "root ainda entra pelo SSH"; else passa "root trancado no SSH"; fi
if ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -o PubkeyAuthentication=no -o PreferredAuthentications=password \
     -o NumberOfPasswordPrompts=0 "hermes@$IP" true 2>&1 | grep -q 'Permission denied (publickey'; then passa "senha recusada no SSH"
else cai "SSH ainda oferece senha"; fi

echo "== Segurança"
confere "firewall ligado"                h "sudo -n ufw status | grep -q 'Status: active'"
confere "firewall só com a porta do SSH" h "[ \$(sudo -n ufw status | grep -c ALLOW) -le 2 ]"
confere "fail2ban rodando"               h "systemctl is-active --quiet fail2ban"
confere "atualização automática ligada"  h "systemctl is-enabled --quiet unattended-upgrades"

echo "== Hermes e agentes"
confere "Hermes no commit 99fcd69 (base 0.22)" h "~/.local/bin/hermes --version | grep -q 'v0.22.5'"
for p in mkt-atendimento mkt-conteudo mkt-landing; do
  confere "serviço imersao-$p ligado" h "systemctl is-active --quiet imersao-$p"
  r=$(h "timeout 180 ~/.local/bin/hermes -p $p -z 'Responda em uma frase curta quem você é.'" 2>/dev/null | tr '\n' ' ')
  if [ -n "$r" ] && [[ "$r" != *"⚠️"* ]]; then passa "$p respondeu: ${r:0:100}"; else cai "$p não respondeu"; fi
done
confere "Telegram configurado nos 3" h 'for p in mkt-atendimento mkt-conteudo mkt-landing; do grep -q "^TELEGRAM_ALLOWED_USERS=." ~/.hermes/profiles/$p/.env || exit 1; done'
if h 'grep -q "^WHATSAPP_ENABLED=true" ~/.hermes/profiles/mkt-atendimento/.env' 2>/dev/null; then
  passa "WhatsApp ligado no Atendimento"
  confere "WhatsApp só no Atendimento" h '! grep -qs "^WHATSAPP_ENABLED=true" ~/.hermes/profiles/mkt-conteudo/.env ~/.hermes/profiles/mkt-landing/.env'
  confere "WhatsApp sem terminal nem arquivos" h "grep -A3 '^platform_toolsets:' ~/.hermes/profiles/mkt-atendimento/config.yaml | grep -q search && ! grep -A4 '^platform_toolsets:' ~/.hermes/profiles/mkt-atendimento/config.yaml | grep -Eq 'terminal|file'"
else
  echo "  · WhatsApp do Atendimento não ligado (opcional)"
fi
confere "nenhum token no registro" h "! sudo -n grep -Eq '[0-9]{8,10}:AA[A-Za-z0-9_-]{30,}|sk-[A-Za-z0-9_-]{16,}' /var/log/imersao-instalador.log"

echo "== Carga: os 3 agentes respondendo ao mesmo tempo (plano recomendado: KVM 2)"
h "nproc; free -m | awk '/^Mem:/{print \$2}'" 2>/dev/null | paste -sd' ' | { read -r cpus memtot; echo "  · máquina: ${cpus:-?} vCPU, ${memtot:-?} MB de RAM"; }
# Amostra RAM (usada e disponível), swap e CPU a cada 1 s enquanto os 3 respondem em paralelo; mostra o pico.
r=$(h 'set -u; out=$(mktemp -d); t0=$(date +%s)
  for p in mkt-atendimento mkt-conteudo mkt-landing; do
    ( timeout 240 ~/.local/bin/hermes -p $p -z "Em três frases, explique o que você faz e dê um exemplo de tarefa." > $out/$p 2>&1 ) &
  done
  picou=0; minav=999999; picsw=0; picpu=0
  set -- $(free -m | awk "/^Mem:/{print \$3} /^Swap:/{print \$3}"); base=$1; basesw=${2:-0}
  read -r _ a b c d e f g _ < /proc/stat; ant=$((a+b+c+d+e+f+g)); antid=$((d+e))
  while [ -n "$(jobs -r)" ]; do
    sleep 1
    read -r _ a b c d e f g _ < /proc/stat; tot=$((a+b+c+d+e+f+g)); id=$((d+e))
    cpu=$(( 100 * ((tot-ant) - (id-antid)) / ((tot-ant) > 0 ? (tot-ant) : 1) )); ant=$tot; antid=$id
    set -- $(free -m | awk "/^Mem:/{print \$3, \$7} /^Swap:/{print \$3}")
    [ "$1" -gt "$picou" ] && picou=$1; [ "$2" -lt "$minav" ] && minav=$2; sw=$(( ${3:-0} - basesw )); [ "$sw" -gt "$picsw" ] && picsw=$sw; [ "$cpu" -gt "$picpu" ] && picpu=$cpu
  done
  wait
  bons=0; for p in mkt-atendimento mkt-conteudo mkt-landing; do [ -s $out/$p ] && ! grep -q "⚠️" $out/$p && bons=$((bons+1)); done
  oom=$(sudo -n journalctl -k --since "-10min" 2>/dev/null | grep -ci "out of memory\|oom-kill" || true)
  echo "$bons $picou $(( picou - base )) $minav $picsw $picpu $(( $(date +%s) - t0 )) ${oom:-0}"; rm -rf $out' 2>/dev/null)
read -r bons picou subiu minav picsw picpu seg oom <<< "${r:-0 0 0 0 0 0 0 0}"
echo "  · pico de RAM usada ${picou} MB (+${subiu} MB com os 3) · menor RAM livre ${minav} MB · swap +${picsw} MB · pico de CPU ${picpu}% · ${seg} s"
[ "$bons" = 3 ] && passa "os 3 responderam juntos" || cai "só $bons de 3 responderam juntos"
[ "$minav" -ge 1024 ] && passa "sobrou 1 GB ou mais de RAM no pico" || cai "RAM livre caiu para ${minav} MB no pico (menos de 1 GB)"
[ "$picsw" -le 256 ] && passa "sem uso relevante de swap" || cai "o swap cresceu ${picsw} MB durante o teste"
[ "$oom" = 0 ] && passa "nenhum processo morto por falta de memória" || cai "o kernel matou processo por falta de memória"
[ "$seg" -le 180 ] && passa "os 3 terminaram em até 3 min" || cai "levou ${seg} s para os 3 terminarem"

if [ "$REINICIAR" = --reiniciar ]; then
  echo "== Reinício"
  h "sudo -n systemctl reboot" 2>/dev/null || true
  sleep 20; n=0; until h true 2>/dev/null || [ $n -ge 30 ]; do sleep 10; n=$((n + 1)); done
  sleep 30
  for p in mkt-atendimento mkt-conteudo mkt-landing; do
    confere "imersao-$p voltou sozinho" h "systemctl is-active --quiet imersao-$p"
  done
fi
echo; echo "Resultado: $ok ok, $falha falha(s)."
[ "$falha" -eq 0 ]

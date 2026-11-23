#!/usr/bin/env bash
# Confere, de fora, uma VPS em que o instalador já rodou. Não muda nada na VPS (só o --reiniciar reinicia).
# Uso: testes/conferir-vps.sh <ip> <chave-ssh> [--reiniciar]
# Antes, na VPS nova (Ubuntu 24.04), como root:
#   curl -fsSL https://redpro.com.br/instalar -o instalar.sh && bash instalar.sh
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
confere "Hermes v0.22.5" h "~/.local/bin/hermes --version | grep -q 'v0.22.5'"
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

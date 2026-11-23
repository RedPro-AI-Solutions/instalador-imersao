#!/usr/bin/env bash
# =============================================================================
#  Instalador da Imersão Arquiteto de Agentes
#  Prepara uma VPS Ubuntu nova (Hostinger ou outra) com o Hermes e os 3 agentes
#  do Squad de marketing: atendimento, carrosséis e landing pages.
#
#  Uso (uma linha, como root na VPS, de preferência pelo Console web da Hostinger):
#     curl -fsSL "https://redpro.com.br/instalar?k=CHAVE" -o instalar.sh && bash instalar.sh
#  O comando com a CHAVE da aula só aparece em redpro.com.br/configurar-vps, depois da senha.
#
#  Rodar de novo é seguro: cada etapa confere o que já está pronto e pula.
#  Opções:
#     --so <etapa>        roda só uma etapa (ex.: --so telegram, --so cerebro)
#     --refazer <etapa>   refaz uma etapa que já tinha sido concluída
#     --pacote <arquivo>  usa um pacote .tar.gz local em vez de baixar
#     --listar            mostra as etapas e o que já está pronto
#     --agente            modo para agente de terminal (Claude Code, Codex, Gemini CLI):
#                         faz tudo o que não precisa de você e, no fim, lista os passos com
#                         login, token ou teste de acesso para você rodar no SEU terminal.
#                         Liga sozinho quando não há terminal interativo.
#     --cerebro <qual>    claude ou chatgpt (evita a pergunta; útil no modo agente)
#  Etapas: sistema atualizar usuario firewall ssh hermes cerebro agentes
#          telegram whatsapp servico conferir onboarding
#
#  Segurança: nenhum token aparece na tela nem vai para o log. Tokens são
#  digitados escondidos e guardados em arquivo que só o usuário hermes lê.
#  No modo agente nenhum token, senha ou login passa pelo agente: esses passos
#  ficam para a pessoa, no terminal dela.
# =============================================================================
set -Eeuo pipefail
umask 022

# ---------------------------------------------------------------- versões fixas
HERMES_COMMIT="99fcd6944360925943688d30c39ec9a490ccdeb1"   # Hermes v0.22.5
HERMES_VERSAO="v0.22.5"
PLUGIN_CLAUDE_REPO="NousResearch/hermes-plugin-claude-subscription-directsdk"
PLUGIN_CLAUDE_REF="bfe6d9f0b76309f1731ba00c9fc0034f910e7aac"
PLUGIN_CLAUDE_NOME="claude-subscription-directsdk-experimental"
CLAUDE_CODE_VERSAO="2.1.312"
MODELO_CLAUDE="claude-sonnet-5-5"
MODELO_CHATGPT="gpt-5.5"
PACOTE_VERSAO="v1.0.1"
# Chave da aula: a página protegida (redpro.com.br/configurar-vps) entrega este script com a chave no lugar do marcador.
# O pacote sai pela mesma rota protegida, com essa chave, e é conferido pelo sha256 abaixo.
CHAVE="${IMERSAO_CHAVE:-__IMERSAO_CHAVE__}"
PACOTE_URL="${PACOTE_URL:-https://redpro.com.br/instalar/arquivo/pacote-squad.tar.gz?k=$CHAVE}"
PACOTE_SHA256="ff0a32af208de51e5ed89befd01af2482e3c7ccf99dc5bc6285fdafe5d38d2ca"

# ---------------------------------------------------------------- caminhos
U="hermes"
UHOME="/home/$U"
ESTADO="/var/lib/imersao-instalador"
LOG="/var/log/imersao-instalador.log"
PACOTE_DIR="/opt/imersao/pacote"
MARCA_DIR="$UHOME/marca"
AGENTES=(mkt-atendimento mkt-conteudo mkt-landing)
declare -A NOME_AGENTE=([mkt-atendimento]="Atendimento" [mkt-conteudo]="Carrosséis" [mkt-landing]="Landing pages")
ETAPAS=(sistema atualizar usuario firewall ssh hermes cerebro agentes telegram whatsapp servico conferir onboarding)

# ---------------------------------------------------------------- aparência
if [ -t 1 ]; then B=$'\e[1m'; VERDE=$'\e[32m'; AMAR=$'\e[33m'; VERM=$'\e[31m'; AZUL=$'\e[36m'; R=$'\e[0m'
else B=""; VERDE=""; AMAR=""; VERM=""; AZUL=""; R=""; fi

log()    { printf '%s %s\n' "$(date '+%F %T')" "$*" >>"$LOG"; }
MARCA="RedPro Academy"
CURSO="Imersão Arquiteto de Agentes"
titulo() { printf '\n%s━━━ Etapa %s/%s · %s%s  %s· %s%s\n' "$B$AZUL" "$1" "${#ETAPAS[@]}" "$2" "$R" "$AZUL" "$MARCA" "$R"; log "ETAPA $2"; }
fim_etapa() { printf '  %s── %s · etapa %s/%s concluída%s\n' "$AZUL" "$MARCA" "$1" "${#ETAPAS[@]}" "$R"; }
# O que o aluno precisa guardar. Segredo (token, senha) vai só no gerenciador de senhas, nunca em documento.
guarde()   { printf '  %s📌 Guarde isto no seu Google Docs:%s %s\n' "$B$AMAR" "$R" "$*"; }
guarde_segredo() { printf '  %s🔐 Isto é segredo: guarde só no seu gerenciador de senhas, nunca em documento:%s %s\n' "$B$AMAR" "$R" "$*"; }
banner() {
  printf '\n%s' "$B$AZUL"
  printf '  +--------------------------------------------------+\n'
  printf '  |                                                  |\n'
  printf '  |   R E D P R O   A C A D E M Y                    |\n'
  printf '  |   Imersão Arquiteto de Agentes                   |\n'
  printf '  |   Instalador oficial do Squad de agentes         |\n'
  printf '  |                                                  |\n'
  printf '  +--------------------------------------------------+\n'
  printf '%s' "$R"
}
porque() { printf '%s  Por quê:%s %s\n' "$AMAR" "$R" "$*"; }
faz()    { printf '  → %s\n' "$*"; log "$*"; }
ok()     { printf '  %s✔ %s%s\n' "$VERDE" "$*" "$R"; log "OK $*"; }
pula()   { printf '  %s✔ Já estava pronto:%s %s\n' "$VERDE" "$R" "$*"; log "PULA $*"; }
aviso()  { printf '  %s! %s%s\n' "$AMAR" "$*" "$R"; log "AVISO $*"; }
erro()   { printf '\n%s✖ %s%s\n' "$VERM" "$*" "$R" >&2; log "ERRO $*"; exit 1; }

trap 'erro "Algo falhou na linha $LINENO. Nada foi perdido: rode de novo (sudo instalar-imersao) que o instalador continua de onde parou. Detalhes em $LOG."' ERR

# Perguntas sempre leem do teclado, mesmo quando o script veio por "curl | bash".
TTY=/dev/tty
# Programas em Node/Bun (login do Claude) não leem teclado por "/dev/tty" atrás do sudo:
# usa o caminho real do terminal (/dev/pts/N) quando dá para descobrir.
__t=$(ps -o tty= -p $$ 2>/dev/null | tr -d ' ') || true
if [[ "$__t" =~ ^(pts/[0-9]+|tty[0-9]*)$ ]] && [ -c "/dev/$__t" ]; then TTY="/dev/$__t"; fi
pergunta() { local __v; read -r -p "  $1 " __v <"$TTY"; printf '%s' "$__v"; }
segredo()  { local __v; read -r -s -p "  $1 " __v <"$TTY"; echo >"$TTY"; printf '%s' "$__v"; }
sim()      { local r; r=$(pergunta "$1 [s/n]"); [[ "${r,,}" =~ ^(s|sim|y|yes)$ ]]; }

feito()    { [ -f "$ESTADO/$1.ok" ]; }
adiar()    { ADIADA=1; }   # etapa não concluída por escolha/espera do aluno: fica pendente, sem erro
AGENTE=0; CEREBRO_ARG=""; HUMANO=(); OPCIONAL=(); NAO_MARCAR=0
# Modo agente: o passo precisa da pessoa (login, token, teste de acesso). Não pergunta nada:
# registra o que falta, segue com o resto e, no fim, mostra o comando para a pessoa rodar.
humano()   { HUMANO+=("$1|$2"); aviso "Fica para você, no seu terminal: $2"; adiar; }
tem_terminal() { ( : <"$TTY" ) 2>/dev/null; }
marcar()   { date '+%F %T' >"$ESTADO/$1.ok"; }
comoh()    { sudo -u "$U" -H env PATH="$UHOME/.local/bin:/usr/local/bin:/usr/bin:/bin" "$@"; }
hermes_h() { comoh "$UHOME/.local/bin/hermes" "$@"; }

# Grava CHAVE=valor no .env de um agente sem mostrar o valor e sem duplicar a linha.
env_set() {
  local arq="$1" chave="$2" valor="$3"
  install -o "$U" -g "$U" -m 600 /dev/null "$arq.tmp"
  [ -f "$arq" ] && grep -v "^${chave}=" "$arq" >"$arq.tmp" || true
  printf '%s=%s\n' "$chave" "$valor" >>"$arq.tmp"
  chown "$U:$U" "$arq.tmp"; chmod 600 "$arq.tmp"; mv "$arq.tmp" "$arq"
}
env_get() { [ -f "$1" ] && sed -n "s/^$2=//p" "$1" | tail -1 || true; }

# Chamada à API do Telegram sem o token aparecer na lista de processos (vai pela entrada padrão do curl).
tg() {
  local token="$1" metodo="$2"; shift 2
  printf 'url = "https://api.telegram.org/bot%s/%s"\n' "$token" "$metodo" | curl -fsS --max-time 20 -K - "$@"
}

# Marca como lidas todas as mensagens que o bot já recebeu.
tg_limpar() {
  local u; u=$(tg "$1" getUpdates 2>/dev/null | jq -r '.result | last | .update_id // empty' || true)
  [ -z "$u" ] || tg "$1" getUpdates -d "offset=$((u + 1))" >/dev/null 2>&1 || true
}

# =============================================================================
etapa_sistema() {
  titulo 1 "Conferir a máquina"
  porque "o instalador foi feito para Ubuntu 22.04 ou 24.04. Melhor parar agora do que quebrar no meio."
  [ "$(id -u)" -eq 0 ] || erro "Rode como root (na Hostinger, entre com: ssh root@IP-DA-VPS)."
  . /etc/os-release
  [ "${ID:-}" = "ubuntu" ] || erro "Este sistema é ${PRETTY_NAME:-desconhecido}. Reinstale a VPS com Ubuntu 24.04."
  case "${VERSION_ID:-}" in 22.04|24.04) ok "Ubuntu $VERSION_ID" ;; *) aviso "Ubuntu $VERSION_ID não foi testado. Seguindo mesmo assim." ;; esac
  local ram; ram=$(awk '/MemTotal/{print int($2/1024)}' /proc/meminfo)
  [ "$ram" -ge 1800 ] && ok "Memória: ${ram} MB" || aviso "Memória de ${ram} MB é pouca. O mínimo recomendado é 2 GB (plano KVM 2 da Hostinger)."
  local disco; disco=$(df -Pm / | awk 'NR==2{print $4}')
  [ "$disco" -ge 8000 ] && ok "Disco livre: $((disco/1024)) GB" || erro "Só $((disco/1024)) GB livres no disco. Precisa de pelo menos 8 GB."
  curl -fsS --max-time 10 https://github.com >/dev/null && ok "Internet funcionando" || erro "A VPS não acessa a internet (github.com)."
}

# =============================================================================
etapa_atualizar() {
  titulo 2 "Atualizar o sistema e ligar as atualizações automáticas"
  porque "servidor desatualizado é a porta de entrada mais comum de invasão. As correções de segurança passam a cair sozinhas toda noite."
  export DEBIAN_FRONTEND=noninteractive
  faz "Baixando a lista de atualizações (pode levar alguns minutos)"
  apt-get update -qq >>"$LOG" 2>&1
  faz "Instalando as atualizações"
  apt-get -y -qq -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold upgrade >>"$LOG" 2>&1
  faz "Instalando ferramentas: git, firewall (ufw), fail2ban, atualizações automáticas"
  apt-get -y -qq install curl git ufw fail2ban unattended-upgrades ca-certificates jq tar >>"$LOG" 2>&1
  timedatectl set-timezone America/Sao_Paulo 2>/dev/null || true
  ok "Fuso horário: $(timedatectl show -p Timezone --value 2>/dev/null || echo America/Sao_Paulo)"
  cat >/etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
  systemctl enable --now unattended-upgrades >>"$LOG" 2>&1 || true
  ok "Atualizações de segurança automáticas ligadas"
  if [ -f /var/run/reboot-required ]; then aviso "Uma atualização pede reinício. O instalador avisa no final; não precisa reiniciar agora."; fi
}

# =============================================================================
etapa_usuario() {
  titulo 3 "Criar o usuário hermes e cadastrar a sua chave SSH"
  porque "trabalhar como root é perigoso: qualquer erro vira desastre. Os agentes rodam num usuário só deles, e você entra com uma chave em vez de senha."
  if id "$U" >/dev/null 2>&1; then pula "usuário $U"
  else
    faz "Criando o usuário $U"
    useradd -m -s /bin/bash "$U"
    ok "Usuário $U criado"
  fi
  usermod -aG sudo "$U"
  printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$U" >/etc/sudoers.d/90-imersao-hermes
  chmod 440 /etc/sudoers.d/90-imersao-hermes
  visudo -cf /etc/sudoers.d/90-imersao-hermes >/dev/null
  ok "O $U pode administrar a VPS com sudo (ele não tem senha, então o acesso é só pela chave)"

  install -d -o "$U" -g "$U" -m 700 "$UHOME/.ssh"
  local ak="$UHOME/.ssh/authorized_keys"
  touch "$ak"; chown "$U:$U" "$ak"; chmod 600 "$ak"
  if [ -s "$ak" ] && ssh-keygen -lf "$ak" >/dev/null 2>&1; then
    pula "chave SSH já cadastrada ($(ssh-keygen -lf "$ak" | head -1 | awk '{print $2}'))"
    return
  fi
  if [ -s /root/.ssh/authorized_keys ] && ssh-keygen -lf /root/.ssh/authorized_keys >/dev/null 2>&1; then
    echo "  Achei uma chave que você cadastrou na Hostinger: $(ssh-keygen -lf /root/.ssh/authorized_keys | head -1 | awk '{print $2, $3}')"
    if [ "$AGENTE" = 1 ] || sim "Usar essa mesma chave para o usuário hermes?"; then
      cat /root/.ssh/authorized_keys >>"$ak"; ok "Chave copiada"; guarde "o usuário da VPS é $U e o IP é $(ip_publico)"; return
    fi
  fi
  if [ "$AGENTE" = 1 ]; then humano usuario "cadastrar a sua chave SSH pública (a VPS não tem nenhuma)"; return 0; fi
  echo "  Cole a sua chave PÚBLICA (a linha que começa com ssh-ed25519, do arquivo id_ed25519.pub)."
  echo "  Ela não é segredo: é como o cadeado, não a chave. Veja o Passo 3 do manual se ainda não criou."
  local chave tmp; tmp=$(mktemp)
  while :; do
    chave=$(pergunta "Chave pública:")
    printf '%s\n' "$chave" >"$tmp"
    if [[ "$chave" == ssh-* || "$chave" == ecdsa-* ]] && ssh-keygen -lf "$tmp" >/dev/null 2>&1; then break; fi
    aviso "Isso não parece uma chave pública. Confira se copiou o arquivo .pub inteiro, numa linha só."
  done
  cat "$tmp" >>"$ak"; rm -f "$tmp"
  ok "Chave cadastrada: $(ssh-keygen -lf "$ak" | tail -1 | awk '{print $2}')"
  guarde "o usuário da VPS é $U e o IP é $(ip_publico)"
}

# =============================================================================
ip_publico() { curl -fsS --max-time 8 https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}'; }
porta_ssh() {
  local t p; t=$(sshd -T 2>/dev/null || true)
  p=$(awk '/^port /{print $2}' <<<"$t" | head -1)
  [[ "$p" =~ ^[0-9]+$ ]] && echo "$p" || echo 22
}

etapa_firewall() {
  titulo 4 "Ligar o firewall e o fail2ban"
  porque "a VPS fica na internet aberta e recebe tentativas de invasão em minutos. Só a porta do SSH fica aberta, e quem errar a senha várias vezes é bloqueado."
  local p; p=$(porta_ssh); [ -n "$p" ] || p=22
  ufw default deny incoming >>"$LOG" 2>&1
  ufw default allow outgoing >>"$LOG" 2>&1
  ufw allow "$p/tcp" comment 'SSH' >>"$LOG" 2>&1
  if ufw status | grep -q "Status: active"; then pula "firewall ligado"; else ufw --force enable >>"$LOG" 2>&1; ok "Firewall ligado"; fi
  ok "Aberta só a porta $p (SSH). Os agentes falam com o Telegram por saída, não precisam de porta aberta."
  cat >/etc/fail2ban/jail.d/imersao.local <<EOF
[sshd]
enabled  = true
port     = $p
maxretry = 5
findtime = 10m
bantime  = 1h
EOF
  systemctl enable fail2ban >>"$LOG" 2>&1; systemctl restart fail2ban
  ok "fail2ban ligado: 5 erros em 10 minutos = 1 hora bloqueado"
}

# =============================================================================
etapa_ssh() {
  titulo 5 "Fechar a entrada por senha e a entrada do root"
  porque "senha pode ser adivinhada; chave não. Mas só desligamos a senha DEPOIS de você provar que entra com a chave, para ninguém ficar trancado para fora."
  local conf=/etc/ssh/sshd_config.d/00-imersao.conf
  if [ -f "$conf" ]; then pula "entrada por senha e por root já desligadas"; return; fi
  if [ "$AGENTE" = 1 ]; then
    humano ssh "testar a entrada com a sua chave e só então desligar a senha e o root"; return 0
  fi
  local ip; ip=$(ip_publico)
  local p; p=$(porta_ssh)
  echo
  echo "  ${B}Teste agora, SEM fechar esta janela:${R}"
  echo "  1. Abra OUTRO terminal no seu computador."
  if [ "${p:-22}" = 22 ]; then echo "  2. Digite:  ssh $U@$ip"; else echo "  2. Digite:  ssh -p $p $U@$ip"; fi
  echo "  3. Se entrar sem pedir senha da VPS, deu certo. Pode sair com: exit"
  echo "  Depois de trancado, para rodar o instalador de novo: entre como $U e use  sudo instalar-imersao"
  echo
  if ! sim "Você conseguiu entrar como $U com a chave?"; then
    aviso "Tudo bem. A senha continua ligada por enquanto. Confira o Passo 3 do manual e rode o instalador de novo."
    aviso "As outras etapas seguem normalmente."
    adiar; return 0
  fi
  cat >"$conf" <<'EOF'
# Imersão Arquiteto de Agentes: entrada só por chave, root fechado.
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
EOF
  if ! sshd -t 2>>"$LOG"; then rm -f "$conf"; erro "A configuração do SSH não passou no teste. Nada foi alterado."; fi
  systemctl reload ssh 2>/dev/null || systemctl reload sshd
  ok "Pronto. Daqui em diante entre sempre com: ssh $U@$ip"
  guarde "o comando para entrar na VPS: ssh $U@$ip (usuário $U, IP $ip)"
  aviso "O root não entra mais direto. Para administrar, use o $U e o comando sudo."
}

# =============================================================================
etapa_hermes() {
  titulo 6 "Instalar o Hermes ($HERMES_VERSAO)"
  porque "o Hermes é o motor dos agentes. Instalamos sempre a mesma versão testada na aula, para o seu funcionar igual ao do professor."
  local dir="$UHOME/.hermes/hermes-agent"
  if [ -x "$UHOME/.local/bin/hermes" ] && [ "$(comoh git -C "$dir" rev-parse HEAD 2>/dev/null)" = "$HERMES_COMMIT" ]; then
    pula "Hermes $HERMES_VERSAO"; return
  fi
  faz "Baixando e instalando (5 a 10 minutos; a tela pode ficar parada, é normal)"
  comoh bash -c "curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/$HERMES_COMMIT/scripts/install.sh \
     | bash -s -- --commit $HERMES_COMMIT --non-interactive --skip-computer-use" >>"$LOG" 2>&1 \
     || erro "A instalação do Hermes falhou. Veja o fim de $LOG e rode de novo."
  [ "$(comoh git -C "$dir" rev-parse HEAD 2>/dev/null)" = "$HERMES_COMMIT" ] || erro "O Hermes instalou numa versão diferente da esperada."
  ok "Hermes instalado: $(hermes_h --version 2>/dev/null | head -1)"
}

# =============================================================================
# Depois de um login feito mais tarde (modo agente), os agentes já instalados voltam com o cérebro novo.
religar_agentes() {
  local p
  for p in "${AGENTES[@]}"; do
    [ -f "/etc/systemd/system/imersao-$p.service" ] && systemctl restart "imersao-$p" && sleep 6 || true
  done
}
cerebro_escolhido() { cat "$ESTADO/cerebro" 2>/dev/null || true; }

claude_logado() { comoh env CLAUDE_CONFIG_DIR="$UHOME/.claude" "$UHOME/.local/bin/claude" auth status >/dev/null 2>&1; }
codex_logado()  { local s; s=$(hermes_h auth status openai-codex 2>/dev/null | head -1); [ -n "$s" ] && [[ "$s" != *"logged out"* ]]; }

etapa_cerebro() {
  titulo 7 "Conectar o cérebro dos agentes"
  porque "o agente pensa usando a sua assinatura de IA. Você entra com a sua conta uma vez; nenhuma chave de API, nenhum custo por mensagem."
  local c; c=$(cerebro_escolhido)
  if [ -z "$c" ] && [ -n "$CEREBRO_ARG" ]; then c="$CEREBRO_ARG"; echo "$c" >"$ESTADO/cerebro"; fi
  if [ -z "$c" ] && [ "$AGENTE" = 1 ]; then
    aviso "Falta dizer qual é a assinatura. Pergunte à pessoa (Claude ou ChatGPT) e rode de novo com --agente --cerebro claude (ou --cerebro chatgpt)."
    adiar; return 0
  fi
  if [ -z "$c" ]; then
    echo "  Qual assinatura você tem?"
    echo "    1) Claude (Pro ou Max)"
    echo "    2) ChatGPT (Plus ou Pro)"
    while :; do
      case "$(pergunta "Digite 1 ou 2:")" in 1) c=claude; break ;; 2) c=chatgpt; break ;; esac
    done
    echo "$c" >"$ESTADO/cerebro"
  fi
  if [ "$c" = claude ]; then
    if [ "$(comoh "$UHOME/.local/bin/claude" --version 2>/dev/null | awk '{print $1}')" != "$CLAUDE_CODE_VERSAO" ]; then
      faz "Instalando o Claude Code $CLAUDE_CODE_VERSAO (é por ele que o agente usa a sua assinatura)"
      comoh bash -c "curl -fsSL https://claude.ai/install.sh | bash -s $CLAUDE_CODE_VERSAO" >>"$LOG" 2>&1 \
        || erro "Não consegui instalar o Claude Code. Veja $LOG e rode de novo."
    else pula "Claude Code $CLAUDE_CODE_VERSAO"; fi
    install -d -o "$U" -g "$U" -m 700 "$UHOME/.claude"
    if claude_logado; then pula "assinatura do Claude conectada"; return; fi
    if [ "$AGENTE" = 1 ]; then humano cerebro "entrar com a sua conta do Claude (abre um link e você cola o código)"; return 0; fi
    echo
    echo "  Vai aparecer um link. Abra no navegador do SEU computador, entre na sua conta do Claude,"
    echo "  clique em Autorizar e cole aqui o código que aparecer. O código vale só uma vez."
    echo
    comoh env CLAUDE_CONFIG_DIR="$UHOME/.claude" "$UHOME/.local/bin/claude" auth login <"$TTY" >"$TTY" 2>&1 || true
    if claude_logado; then ok "Assinatura do Claude conectada"; religar_agentes
    else aviso "O login do Claude não terminou. Sigo com o resto; depois rode: sudo instalar-imersao --so cerebro"; adiar; fi
  else
    if codex_logado; then pula "assinatura do ChatGPT conectada"; return; fi
    if [ "$AGENTE" = 1 ]; then humano cerebro "entrar com a sua conta do ChatGPT (abre um link e você digita um código)"; return 0; fi
    echo
    echo "  Vai aparecer um link e um código curto. Abra o link no navegador do SEU computador,"
    echo "  entre na sua conta do ChatGPT e digite o código. Depois volte aqui."
    echo
    hermes_h auth add openai-codex --type oauth --no-browser <"$TTY" >"$TTY" 2>&1 || true
    if codex_logado; then ok "Assinatura do ChatGPT conectada"; religar_agentes
    else aviso "O login do ChatGPT não terminou. Sigo com o resto; depois rode: sudo instalar-imersao --so cerebro"; adiar; fi
  fi
}

# =============================================================================
baixar_pacote() {
  # Guarda o pacote conferido na VPS: o --refazer não baixa de novo (a chave da aula pode ter mudado).
  local cache="$ESTADO/pacote-${PACOTE_SHA256:0:16}.tar.gz"
  if [ -n "${PACOTE_LOCAL:-}" ]; then
    faz "Usando o pacote local $PACOTE_LOCAL"; cp "$PACOTE_LOCAL" /tmp/imersao-pacote.tar.gz
  elif [ -n "$PACOTE_SHA256" ] && [ -s "$cache" ]; then
    faz "Usando o pacote dos agentes já baixado"; cp "$cache" /tmp/imersao-pacote.tar.gz
  else
    [ "$CHAVE" != "__IMERSAO_""CHAVE__" ] || erro "Este instalador veio sem a chave da aula. Copie o comando da página redpro.com.br/configurar-vps e rode de novo."
    faz "Baixando o pacote dos agentes"
    curl -fsSL --max-time 120 "$PACOTE_URL" -o /tmp/imersao-pacote.tar.gz \
      || erro "Não consegui baixar o pacote dos agentes. Se a senha da aula mudou, copie o comando novo da página redpro.com.br/configurar-vps."
  fi
  if [ -n "$PACOTE_SHA256" ]; then
    echo "$PACOTE_SHA256  /tmp/imersao-pacote.tar.gz" | sha256sum -c --quiet - \
      || erro "O pacote baixado não confere com a assinatura esperada. Não vou instalar nada dele."
    ok "Pacote conferido (sha256)"
    cp /tmp/imersao-pacote.tar.gz "$cache"; chmod 600 "$cache"
  fi
  rm -rf "$PACOTE_DIR.novo"; install -d "$PACOTE_DIR.novo"
  tar -xzf /tmp/imersao-pacote.tar.gz -C "$PACOTE_DIR.novo" --no-same-owner
  rm -rf "$PACOTE_DIR"; mv "$PACOTE_DIR.novo" "$PACOTE_DIR"
  chmod -R a+rX "$PACOTE_DIR"; rm -f /tmp/imersao-pacote.tar.gz
}

aplicar_cerebro() {
  local p="$1" c; c=$(cerebro_escolhido)
  local envf="$UHOME/.hermes/profiles/$p/.env"
  if [ "$c" = claude ]; then
    if [ ! -d "$UHOME/.hermes/profiles/$p/plugins/$PLUGIN_CLAUDE_NOME" ]; then
      hermes_h -p "$p" plugins install "$PLUGIN_CLAUDE_REPO" --ref "$PLUGIN_CLAUDE_REF" --yes-deps --enable >>"$LOG" 2>&1
    else
      hermes_h -p "$p" plugins enable "$PLUGIN_CLAUDE_NOME" >>"$LOG" 2>&1 || true
    fi
    hermes_h -p "$p" config set model.provider "$PLUGIN_CLAUDE_NOME" >>"$LOG" 2>&1
    hermes_h -p "$p" config set model.default "$MODELO_CLAUDE" >>"$LOG" 2>&1
    env_set "$envf" CLAUDE_CONFIG_DIR "$UHOME/.claude"
  else
    hermes_h -p "$p" config set model.provider openai-codex >>"$LOG" 2>&1
    hermes_h -p "$p" config set model.default "$MODELO_CHATGPT" >>"$LOG" 2>&1
  fi
  hermes_h -p "$p" config set gateway.standalone true >>"$LOG" 2>&1
  hermes_h -p "$p" config set timezone America/Sao_Paulo >>"$LOG" 2>&1
}

etapa_agentes() {
  titulo 8 "Instalar os 3 agentes do Squad"
  porque "cada agente é um perfil separado no Hermes, com a própria personalidade (SOUL), habilidades e memória. Um não mexe nas coisas do outro."
  if [ -z "$(cerebro_escolhido)" ]; then
    [ "$AGENTE" = 1 ] || erro "Escolha o cérebro antes: sudo instalar-imersao --so cerebro"
    aviso "Os agentes esperam a escolha da assinatura (--cerebro claude ou --cerebro chatgpt)."; adiar; return 0
  fi
  baixar_pacote
  if [ -d "$MARCA_DIR" ]; then
    faz "A pasta da sua marca já existe: só acrescento arquivos que faltam, sem mexer no que você escreveu"
    cp -r --update=none "$PACOTE_DIR/marca/." "$MARCA_DIR/"
  else
    cp -r "$PACOTE_DIR/marca" "$MARCA_DIR"
  fi
  chown -R "$U:$U" "$MARCA_DIR"
  ok "Modelos da sua marca em $MARCA_DIR (em branco: o onboarding preenche com você)"
  local p
  for p in "${AGENTES[@]}"; do
    faz "Agente ${NOME_AGENTE[$p]} ($p)"
    # --force atualiza os arquivos do agente e preserva memória, sessões e o .env.
    hermes_h profile install "$PACOTE_DIR/agentes/$p" --name "$p" --force -y >>"$LOG" 2>&1 \
      || erro "Não consegui instalar o agente $p. Veja $LOG."
    aplicar_cerebro "$p"
    ok "${NOME_AGENTE[$p]} instalado"
  done
}

# =============================================================================
etapa_telegram() {
  titulo 9 "Dar um bot do Telegram para cada agente"
  porque "é pelo Telegram que você conversa com cada agente. Cada um tem o próprio bot, e só VOCÊ consegue falar com ele."
  local p envf token tid nome usuario faltam=()
  for p in "${AGENTES[@]}"; do
    envf="$UHOME/.hermes/profiles/$p/.env"
    token=$(env_get "$envf" TELEGRAM_BOT_TOKEN)
    if [ -n "$token" ] && [ -n "$(env_get "$envf" TELEGRAM_ALLOWED_USERS)" ] && tg "$token" getMe >/dev/null 2>&1; then
      pula "bot do agente ${NOME_AGENTE[$p]}"; continue
    fi
    if [ "$AGENTE" = 1 ]; then faltam+=("${NOME_AGENTE[$p]}"); continue; fi
    echo
    echo "  ${B}Bot do agente ${NOME_AGENTE[$p]}${R}"
    echo "  No Telegram, fale com @BotFather → /newbot → dê um nome → ele te entrega um token."
    echo "  Ainda não criou o bot? Digite pular: os outros passos seguem e depois você roda: sudo instalar-imersao --so telegram"
    guarde_segredo "o token do bot (o instalador não mostra nem grava ele em lugar nenhum além da VPS)"
    usuario=""
    while :; do
      token=$(segredo "Cole o token do bot (não aparece na tela):")
      [ -n "$token" ] || continue
      [ "${token,,}" = pular ] && break
      if usuario=$(tg "$token" getMe 2>/dev/null | jq -r '.result.username // empty') && [ -n "$usuario" ]; then break; fi
      aviso "O Telegram não aceitou esse token. Copie de novo a mensagem do BotFather."
    done
    if [ -z "$usuario" ]; then aviso "Bot do agente ${NOME_AGENTE[$p]} ficou para depois."; unset token; adiar; continue; fi
    ok "Bot @$usuario conferido"
    guarde "o bot do agente ${NOME_AGENTE[$p]} é @$usuario (t.me/$usuario)"
    systemctl stop "imersao-$p" 2>/dev/null || true   # o serviço ligado "come" as mensagens que vamos ler agora
    tg "$token" deleteWebhook >/dev/null 2>&1 || true
    tg_limpar "$token"   # descarta mensagens antigas: só vale o /start mandado agora
    echo "  Agora abra t.me/$usuario no Telegram e mande /start para o bot."
    tid=""
    while [ -z "$tid" ]; do
      pergunta "Mandou? Aperte Enter." >/dev/null
      tid=$(tg "$token" getUpdates 2>/dev/null | jq -r '[.result[] | .message.from.id // empty] | last // empty')
      [ -n "$tid" ] || { aviso "Ainda não chegou nada. Confira se mandou /start para @$usuario."; continue; }
      nome=$(tg "$token" getUpdates 2>/dev/null | jq -r '[.result[] | .message.from | select(.id != null) | ((.first_name // "") + " " + (.last_name // "") + (if .username then " (@" + .username + ")" else "" end))] | last // ""')
      # Quem mandar /start primeiro vira o dono do bot: confirma que foi o próprio aluno.
      sim "A mensagem veio de: ${nome:-sem nome} (ID $tid). É você?" || { tid=""; tg_limpar "$token"; aviso "Então mande /start de novo, da SUA conta."; }
    done
    env_set "$envf" TELEGRAM_BOT_TOKEN "$token"
    env_set "$envf" TELEGRAM_ALLOWED_USERS "$tid"
    env_set "$envf" TELEGRAM_HOME_CHANNEL "$tid"
    unset token
    ok "Bot ligado ao seu Telegram. Mais ninguém consegue usar este agente."
    if [ -f "/etc/systemd/system/imersao-$p.service" ]; then
      systemctl restart "imersao-$p"; sleep 6; ok "Agente ${NOME_AGENTE[$p]} religado com o bot novo"
    fi
  done
  if [ ${#faltam[@]} -gt 0 ]; then
    local lista; lista=$(printf '%s, ' "${faltam[@]}"); lista=${lista%, }
    humano telegram "colar o token do bot do Telegram de cada agente ($lista) e mandar /start para ele"
  fi
}

# =============================================================================
# Só o agente de Atendimento (o SDR) fica no WhatsApp. Os outros dois ficam só no seu Telegram.
WA_AGENTE="mkt-atendimento"
wa_pareado() {
  local h="$UHOME/.hermes/profiles/$WA_AGENTE" f
  for f in "$h/platforms/whatsapp/session/creds.json" "$h/whatsapp/session/creds.json"; do
    [ -f "$f" ] && jq -e '.me.id // empty' "$f" >/dev/null 2>&1 && return 0
  done
  return 1
}

etapa_whatsapp() {
  titulo 10 "Ligar o agente de Atendimento ao WhatsApp do negócio (opcional)"
  porque "o Atendimento é o seu SDR: responde quem chama no WhatsApp do negócio e passa para você o que precisa de gente. Só ele fica no WhatsApp."
  local p="$WA_AGENTE" h="$UHOME/.hermes/profiles/$WA_AGENTE" envf quem py
  envf="$h/.env"
  if wa_pareado && [ "$(env_get "$envf" WHATSAPP_ENABLED)" = true ]; then
    pula "WhatsApp ligado ao agente ${NOME_AGENTE[$p]}"; return 0
  fi
  if [ "$AGENTE" = 1 ]; then
    OPCIONAL+=("whatsapp|ligar o Atendimento ao WhatsApp do negócio (QR code no celular do número do negócio)")
    printf '  · WhatsApp do Atendimento (opcional): fica para você, no seu terminal.\n'
    NAO_MARCAR=1; return 0
  fi
  echo "  Você precisa de um número SÓ do negócio (chip, eSIM ou número virtual, como o da Salvy),"
  echo "  com o WhatsApp Business já ativado nele num celular. Não use o seu número pessoal."
  if ! sim "Esse número já está com o WhatsApp Business funcionando?"; then
    aviso "Sem problema. Quando o número estiver pronto, rode: sudo instalar-imersao --so whatsapp"
    return 0
  fi
  # Cópia de segurança do perfil antes de mexer (só configuração; sem sessões).
  install -d -m 700 -o "$U" -g "$U" "$h/backups"
  tar -czf "$h/backups/antes-whatsapp-$(date +%Y%m%d-%H%M%S).tar.gz" -C "$h" config.yaml $( [ -f "$envf" ] && echo .env ) 2>>"$LOG" || true
  chown -R "$U:$U" "$h/backups"; chmod 600 "$h"/backups/*.tar.gz 2>/dev/null || true
  echo
  echo "  Quem pode conversar com o Atendimento?"
  echo "  Aperte Enter para QUALQUER pessoa (seus leads). Para um teste fechado, digite os números"
  echo "  com 55 + DDD + número, tudo junto, separados por vírgula."
  quem=$(pergunta "Números (ou Enter para todos):")
  quem=$(tr -cd '0-9,' <<<"$quem" | sed 's/,,*/,/g; s/^,//; s/,$//')
  [ -n "$quem" ] || quem='*'
  env_set "$envf" WHATSAPP_MODE bot
  env_set "$envf" WHATSAPP_ALLOWED_USERS "$quem"
  # Sem o selo "Hermes Agent" nas respostas, sem grupos e, para estranhos, só ferramentas seguras
  # (ler as próprias habilidades e pesquisar na web): ninguém de fora mexe em arquivos ou no terminal.
  py="$UHOME/.hermes/hermes-agent/venv/bin/python"
  comoh "$py" - "$h/config.yaml" "$quem" <<'EOF' >>"$LOG" 2>&1 || erro "Não consegui ajustar a configuração do WhatsApp. Veja $LOG."
import sys, yaml
f, quem = sys.argv[1], sys.argv[2]
c = yaml.safe_load(open(f)) or {}
c.setdefault("whatsapp", {}).update({"reply_prefix": "", "group_policy": "disabled",
    "unauthorized_dm_behavior": "ignore", "dm_policy": "open" if quem == "*" else "allowlist"})
c.setdefault("platform_toolsets", {})["whatsapp"] = ["skills", "search"]
yaml.safe_dump(c, open(f, "w"), allow_unicode=True, sort_keys=False)
EOF
  ok "Atendimento configurado para o WhatsApp (${quem/\*/qualquer pessoa})"
  systemctl stop "imersao-$p" 2>/dev/null || true   # o pareamento usa a mesma sessão do serviço
  echo
  echo "  ${B}Agora o QR code.${R} Vai aparecer um quadrado na tela. No celular do número do negócio:"
  echo "  WhatsApp Business → três pontinhos (ou Configurações) → Dispositivos conectados → Conectar dispositivo"
  echo "  → aponte a câmera para o quadrado. Se a tela for pequena, diminua o zoom do terminal (Ctrl e -)."
  echo "  Se aparecer uma pergunta em inglês com [y/N], só aperte Enter."
  pergunta "Pronto para ver o QR? Aperte Enter." >/dev/null
  comoh "$UHOME/.local/bin/hermes" -p "$p" whatsapp <"$TTY" >"$TTY" 2>&1 || true
  if wa_pareado; then
    env_set "$envf" WHATSAPP_ENABLED true
    ok "WhatsApp do negócio conectado ao agente ${NOME_AGENTE[$p]}"
    if [ -f "/etc/systemd/system/imersao-$p.service" ]; then
      systemctl restart "imersao-$p"; sleep 6; ok "Agente ${NOME_AGENTE[$p]} religado com o WhatsApp"
    fi
    echo "  Teste: de OUTRO celular, mande um oi para o número do negócio. O Atendimento responde."
  else
    aviso "O WhatsApp não confirmou a conexão. Rode de novo: sudo instalar-imersao --so whatsapp"
    [ -f "/etc/systemd/system/imersao-$p.service" ] && systemctl start "imersao-$p" || true
    adiar
  fi
}

# =============================================================================
etapa_servico() {
  titulo 11 "Deixar os agentes ligados 24 horas"
  porque "como serviço do sistema, cada agente liga sozinho quando a VPS reinicia e volta se cair."
  local p unit
  if ! feito agentes; then aviso "Os agentes ainda não foram instalados; o serviço fica para depois."; adiar; return 0; fi
  for p in "${AGENTES[@]}"; do
    unit="/etc/systemd/system/imersao-$p.service"
    cat >"$unit.novo" <<EOF
[Unit]
Description=Agente ${NOME_AGENTE[$p]} ($p) do Squad da Imersão
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$U
Group=$U
WorkingDirectory=$UHOME
Environment=HOME=$UHOME
Environment=PATH=$UHOME/.local/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=$UHOME/.local/bin/hermes -p $p gateway run
Restart=on-failure
RestartSec=10
MemoryMax=900M
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    if cmp -s "$unit.novo" "$unit"; then rm -f "$unit.novo"; else mv "$unit.novo" "$unit"; fi
  done
  systemctl daemon-reload
  for p in "${AGENTES[@]}"; do
    systemctl enable "imersao-$p" >>"$LOG" 2>&1
    systemctl restart "imersao-$p"
    sleep 6   # um de cada vez: ligados juntos, eles disputam a mesma trava no primeiro segundo
    ok "${NOME_AGENTE[$p]} ligado (serviço imersao-$p)"
  done
}

# Espera até 60 s o serviço ficar ligado e parar de reiniciar (na partida ele pode tentar de novo uma vez).
servico_firme() {
  local u="$1" n=0 r1 r2
  while [ $n -lt 12 ]; do
    r1=$(systemctl show "$u" -p NRestarts --value); sleep 5
    r2=$(systemctl show "$u" -p NRestarts --value)
    systemctl is-active --quiet "$u" && [ "$r1" = "$r2" ] && return 0
    n=$((n + 1))
  done
  return 1
}

# =============================================================================
etapa_conferir() {
  titulo 12 "Conferência final"
  porque "instalação só está pronta quando cada agente responde de verdade."
  local p falhas=0 resp rc envf token tid
  for p in "${AGENTES[@]}"; do
    servico_firme "imersao-$p" || true
    if systemctl is-active --quiet "imersao-$p"; then ok "Serviço imersao-$p rodando"
    else aviso "Serviço imersao-$p parado. Veja: journalctl -u imersao-$p -n 50"; falhas=$((falhas+1)); continue; fi
    resp=$(timeout 180 sudo -u "$U" -H env PATH="$UHOME/.local/bin:/usr/local/bin:/usr/bin:/bin" \
      "$UHOME/.local/bin/hermes" -p "$p" -z "Responda em uma frase curta, em português, quem você é e o que faz." 2>>"$LOG") && rc=0 || rc=$?
    # Só vale resposta de verdade: código de saída 0 e nenhum aviso de erro do Hermes no lugar da resposta.
    if [ "$rc" -eq 0 ] && [ -n "$resp" ] && [[ "$resp" != *"⚠️"* ]] && [[ "$resp" != *"not processed"* ]]; then
      resp=$(tr '\n' ' ' <<<"$resp")
      ok "${NOME_AGENTE[$p]} pensou e respondeu: ${resp:0:160}"
      envf="$UHOME/.hermes/profiles/$p/.env"; token=$(env_get "$envf" TELEGRAM_BOT_TOKEN); tid=$(env_get "$envf" TELEGRAM_ALLOWED_USERS)
      if [ -n "$token" ] && [ -n "$tid" ]; then
        tg "$token" sendMessage -H 'Content-Type: application/json' \
          -d "$(jq -nc --arg c "$tid" --arg t "Oi! Sou o agente de ${NOME_AGENTE[$p]} e já estou no ar. Pode me chamar por aqui." '{chat_id:$c,text:$t}')" >/dev/null 2>&1 \
          && ok "Mensagem de boas-vindas enviada no seu Telegram" || aviso "Não consegui mandar a mensagem no Telegram."
      fi
      unset token
    else
      aviso "${NOME_AGENTE[$p]} não respondeu: ${resp:0:160}"
      aviso "Quase sempre é o login do cérebro: sudo instalar-imersao --refazer cerebro"
      falhas=$((falhas+1))
    fi
  done
  if wa_pareado && [ "$(env_get "$UHOME/.hermes/profiles/$WA_AGENTE/.env" WHATSAPP_ENABLED)" = true ]; then
    ok "WhatsApp do negócio ligado ao agente ${NOME_AGENTE[$WA_AGENTE]}"
  else
    printf '  · WhatsApp do Atendimento ainda não ligado (opcional): sudo instalar-imersao --so whatsapp\n'
  fi
  [ "$falhas" -eq 0 ] || adiar
}

# =============================================================================
etapa_onboarding() {
  titulo 13 "Onboarding dos agentes"
  porque "é a conversa em que cada agente aprende sobre o seu negócio e preenche os arquivos da sua marca."
  if [ -x "$PACOTE_DIR/onboarding/rodar.sh" ] && [ "$AGENTE" = 1 ]; then
    humano onboarding "conversar com os agentes no onboarding sobre o seu negócio"
  elif [ -x "$PACOTE_DIR/onboarding/rodar.sh" ]; then
    "$PACOTE_DIR/onboarding/rodar.sh" "$U" "$MARCA_DIR"
  else
    aviso "O onboarding guiado será liberado na próxima aula. Quando sair, rode: sudo instalar-imersao --so onboarding"
    adiar
  fi
}

# =============================================================================
rodar_etapa() {
  local e="$1" forcar="${2:-}"
  if feito "$e" && [ -z "$forcar" ]; then
    printf '%s✔ %s%s já concluída em %s\n' "$VERDE" "$e" "$R" "$(cat "$ESTADO/$e.ok")"
    return 0
  fi
  ADIADA=0; NAO_MARCAR=0
  "etapa_$e"
  if [ "$ADIADA" = 1 ]; then PENDENTES+=("$e"); elif [ "$NAO_MARCAR" = 0 ]; then marcar "$e"; fi
  local i n=0; for i in "${!ETAPAS[@]}"; do [ "${ETAPAS[$i]}" = "$e" ] && n=$((i + 1)); done
  [ "$ADIADA" = 1 ] || [ "$NAO_MARCAR" = 1 ] || fim_etapa "$n"
}

# Fim do modo agente: o que a PESSOA roda no próprio terminal, com o comando exato.
# Tokens, senhas e logins só são digitados ali, nunca no chat do agente.
resumo_agente() {
  if [ ${#HUMANO[@]} -eq 0 ] && [ ${#OPCIONAL[@]} -eq 0 ]; then echo; echo "PENDENTES_DA_PESSOA="; return 0; fi
  local ip p porta="" quem=root item n=0 ssh_pend=0 e d
  ip=$(ip_publico); p=$(porta_ssh); [ "$p" = 22 ] || porta="-p $p "
  [ -f /etc/ssh/sshd_config.d/00-imersao.conf ] && quem="$U"
  for item in "${HUMANO[@]}"; do [ "${item%%|*}" != ssh ] || ssh_pend=1; done
  local cmd="ssh -t ${porta}${quem}@${ip}"
  echo
  echo "${B}=== Para a pessoa fazer no PRÓPRIO terminal (não no chat do agente) ===${R}"
  if [ ${#HUMANO[@]} -gt 0 ]; then
    echo "Estes passos pedem login, token ou um teste de acesso. Por segurança, nenhum deles passa pelo agente."
    echo
    echo "Jeito mais simples: um comando só, que faz tudo em sequência e pula o que já está pronto:"
    echo "   $cmd 'sudo instalar-imersao'"
    echo
    echo "Ou um de cada vez, nesta ordem:"
    for item in "${HUMANO[@]}"; do   # o teste do SSH vai por último: depois dele o root não entra mais
      e="${item%%|*}"; d="${item#*|}"; [ "$e" != ssh ] || continue
      n=$((n + 1)); echo "   $n. Para $d:"; echo "      $cmd 'sudo instalar-imersao --so $e'"
    done
    if [ "$ssh_pend" = 1 ]; then
      n=$((n + 1))
      echo "   $n. Para testar a entrada com a sua chave e só então desligar a senha e o root:"
      echo "      $cmd 'sudo instalar-imersao --so ssh'"
      echo "      Depois deste passo o root não entra mais. Use:  ssh -t ${porta}${U}@${ip}"
      cmd="ssh -t ${porta}${U}@${ip}"
    fi
    n=$((n + 1)); echo "   $n. No fim, a conferência (cada agente responde e manda um oi no seu Telegram):"
    echo "      $cmd 'sudo instalar-imersao'"
  fi
  for item in "${OPCIONAL[@]}"; do
    e="${item%%|*}"; d="${item#*|}"
    echo
    echo "Opcional: para $d:"
    echo "   $cmd 'sudo instalar-imersao --so $e'"
  done
  local lista="" x
  for x in "${HUMANO[@]}"; do lista+="${x%%|*},"; done
  echo
  echo "PENDENTES_DA_PESSOA=${lista%,}"
}

main() {
  local so="" refazer=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --so) so="$2"; shift 2 ;;
      --refazer) refazer="$2"; shift 2 ;;
      --pacote) PACOTE_LOCAL="$(readlink -f "$2")"; shift 2 ;;
      --agente) AGENTE=1; shift ;;
      --cerebro) case "${2:-}" in claude|chatgpt) CEREBRO_ARG="$2" ;; *) erro "Use --cerebro claude ou --cerebro chatgpt" ;; esac; shift 2 ;;
      --listar) for e in "${ETAPAS[@]}"; do feito "$e" && echo "✔ $e" || echo "· $e"; done; exit 0 ;;
      -h|--help) sed -n '2,29p' "$0"; exit 0 ;;
      *) erro "Opção desconhecida: $1 (use --help)" ;;
    esac
  done
  [ "$(id -u)" -eq 0 ] || erro "Rode como root: sudo bash instalar.sh"
  if [ "$AGENTE" = 0 ] && ! tem_terminal; then
    AGENTE=1
    echo "Sem terminal interativo (parece um agente rodando o instalador): ligando o modo agente."
  fi
  install -d -m 700 "$ESTADO"; touch "$LOG"; chmod 600 "$LOG"
  # Guarda uma cópia fixa: depois que o root é trancado, o aluno roda como hermes com "sudo instalar-imersao".
  if [ -f "$0" ] && [ "$(readlink -f "$0")" != /usr/local/sbin/instalar-imersao ]; then
    install -m 755 "$0" /usr/local/sbin/instalar-imersao
  fi
  PENDENTES=()
  banner
  echo "  Hermes $HERMES_VERSAO · pacote dos agentes $PACOTE_VERSAO"
  [ "$AGENTE" = 0 ] || echo "Modo agente: não pergunto nada. O que precisa de você (login, token, teste de acesso) fica para o fim."
  echo "Registro de tudo em $LOG (sem nenhum token)."
  for e in ${refazer:+$refazer}; do
    rm -f "$ESTADO/$e.ok"
    # Refazer o cérebro deixa trocar de assinatura (Claude <-> ChatGPT) e reaplica nos agentes.
    [ "$e" != cerebro ] || rm -f "$ESTADO/cerebro" "$ESTADO/agentes.ok"
  done
  if [ -n "$so" ]; then
    [[ " ${ETAPAS[*]} " == *" $so "* ]] || erro "Etapa desconhecida: $so. Etapas: ${ETAPAS[*]}"
    rodar_etapa "$so" forcar
  else
    for e in "${ETAPAS[@]}"; do
      case "$e" in   # a checagem da máquina e a conferência final rodam sempre
        sistema) etapa_sistema; continue ;;
        conferir) rodar_etapa conferir forcar; continue ;;
      esac
      rodar_etapa "$e"
    done
  fi
  echo
  if [ ${#PENDENTES[@]} -eq 0 ] && [ -n "$so" ]; then
    echo "${B}${VERDE}Etapa $so concluída.${R}"
  elif [ ${#PENDENTES[@]} -eq 0 ]; then
    echo "${B}${VERDE}Tudo pronto.${R} Abra o Telegram: cada agente já te mandou um oi."
  else
    echo "${B}${AMAR}Quase lá.${R} Ficou pendente: ${PENDENTES[*]}"
    echo "Resolva o que o aviso pediu e rode de novo: sudo instalar-imersao  (o que já está pronto é pulado)"
  fi
  echo
  echo "${B}${AZUL}$MARCA · $CURSO${R}"
  echo "Próximo passo: volte para o manual da $MARCA e siga de onde parou."
  guarde "o IP da VPS ($(ip_publico)), o usuário $U e o nome dos bots dos seus agentes"
  [ "$AGENTE" = 0 ] || resumo_agente
  [ -f /var/run/reboot-required ] && echo "Uma atualização pediu reinício. Quando puder: sudo reboot (os agentes voltam sozinhos)."
  return 0
}

main "$@"

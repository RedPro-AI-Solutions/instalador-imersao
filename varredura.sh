#!/usr/bin/env bash
# Varredura antes de cada push: recusa nome, telefone, e-mail, chave, IP e marca do Red/GenixTech.
# Uso: ./varredura.sh [pasta]   (sai com erro se achar algo)
set -uo pipefail
cd "${1:-$(dirname "$0")}"
ARQS=$(git ls-files 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)
[ -n "$ARQS" ] || ARQS=$(find . -type f -not -path './.git/*' | sed 's|^\./||')
ARQS=$(echo "$ARQS" | grep -vE '^(varredura\.sh|.*\.tar\.gz)$' | sort -u)
# Únicas menções permitidas: o endereço público aprovado do instalador.
PERMITIDO='@example\.com|@company\.com|\*\*Red\*\* \(`#f44336|redpro\.com\.br/instalar|github\.com/RedPro-AI-Solutions/instalador-imersao|RedPro-AI-Solutions/instalador-imersao|raw\.githubusercontent\.com/RedPro-AI-Solutions'
achou=0
checa() { # rótulo, flags do grep, padrão
  local r; r=$(echo "$ARQS" | xargs -d '\n' grep -nHE $2 -- "$3" 2>/dev/null | grep -vE "$PERMITIDO" || true)
  [ -n "$r" ] && { echo "✖ $1:"; echo "$r" | head -20; achou=1; }
}
checa "marca/nome"   -i  'genix|gaguinho|voggar|victor|lllima|redpro|starlight|hermes ?week|amanda|baldan|ladeira|neto\b|rigel|redreply|redflix'
checa "nome Red"     ''  '\bRed\b'
checa "e-mail"       -i  '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}'
checa "telefone"     ''  '(\+?55[ .-]?)?\(?[1-9][0-9]\)?[ .-]?9[0-9]{4}[ .-]?[0-9]{4}\b'
checa "chave/token"  ''  '(sk-[A-Za-z0-9_-]{16,}|gh[opsu]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[abp]-|-----BEGIN [A-Z ]*PRIVATE|eyJ[A-Za-z0-9_-]{20,}\.|[0-9]{8,10}:AA[A-Za-z0-9_-]{30,})'
checa "IP/ID nosso"  ''  '89\.167\.92\.7|179\.236\.224\.179|116\.203\.213\.242|46\.62\.143\.223|8509414578'
if [ "$achou" = 1 ]; then echo; echo "Varredura REPROVADA. Nada de push."; exit 1; fi
echo "Varredura limpa ($(echo "$ARQS" | wc -l) arquivos)."

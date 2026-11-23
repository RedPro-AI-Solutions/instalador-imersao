#!/usr/bin/env bash
# Traz para pacote/agentes/ as versões novas dos 3 perfis do Squad que os donos mexeram no Hermes local.
# Só copia arquivo alterado DEPOIS do último commit do pacote (skill nova vai inteira, sem node_modules): os ajustes feitos só no pacote
# (licenças, textos para o aluno) não são desfeitos. Skills que já vêm com o Hermes ficam de fora.
# Uso: ./sincronizar-perfis.sh            mostra o que mudou (não copia nada)
#      ./sincronizar-perfis.sh --aplicar  copia, roda a varredura e mostra o git diff para revisar
# Depois: revisar o diff, ./construir-pacote.sh, subir PACOTE_VERSAO/PACOTE_SHA256 e publicar a release.
set -euo pipefail
cd "$(dirname "$0")"
ORIGEM="${ORIGEM:-$HOME/.hermes/profiles}"
EMBUTIDAS="${EMBUTIDAS:-$HOME/.hermes/hermes-agent/skills}"
APLICAR=0; [ "${1:-}" = --aplicar ] && APLICAR=1
desde=$(git log -1 --format=%ct -- pacote/agentes)
echo "Arquivos mexidos depois de $(date -d "@$desde" '+%d/%m %H:%M') (último commit do pacote):"
n=0
for p in mkt-atendimento mkt-conteudo mkt-landing; do
  o="$ORIGEM/$p"; d="pacote/agentes/$p"
  [ -d "$o" ] || { echo "  ! $o não existe"; continue; }
  while IFS= read -r -d '' f; do
    rel="${f#"$o"/}"
    novo_skill=0
    case "$rel" in
      skills/*) s="${rel#skills/}"; s="${s%%/*}"
                [ "$s" = PIN.md ] || [ ! -e "$EMBUTIDAS/$s" ] || continue      # skill que já vem com o Hermes
                [ -e "$d/skills/$s" ] || novo_skill=1 ;;                         # skill nova: vai inteira
    esac
    [ "$novo_skill" = 1 ] || [ "$(stat -c %Y "$f")" -gt "$desde" ] || continue
    cmp -s "$f" "$d/$rel" && continue
    echo "  $p/$rel$([ -e "$d/$rel" ] || echo '  (novo)')"
    n=$((n + 1))
    if [ "$APLICAR" = 1 ]; then install -D -m 644 "$f" "$d/$rel"; fi
  done < <(find "$o/SOUL.md" "$o/skills" "$o/golden" "$o/scripts" -type f \
             -not -path '*/node_modules/*' -not -path '*/.locks/*' -not -path '*/__pycache__/*' -not -name '*.pyc' -not -name '.*' -print0 2>/dev/null)
done
echo "$n arquivo(s)."
[ "$APLICAR" = 1 ] && [ "$n" -gt 0 ] || exit 0
chmod 755 pacote/agentes/*/scripts/* 2>/dev/null || true
./varredura.sh pacote || { echo "Corrija o que a varredura apontou (no pacote) antes de seguir."; exit 1; }
git status --short pacote/agentes
echo "Revise com: git diff pacote/agentes"

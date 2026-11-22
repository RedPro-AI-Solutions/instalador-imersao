#!/bin/bash
# Monta o pacote-squad.tar.gz (agentes + modelos de marca) que vai como anexo da release.
# Depois de rodar: suba o arquivo na release e cole o sha256 em PACOTE_SHA256 no instalar.sh.
set -euo pipefail
cd "$(dirname "$0")"
./varredura.sh
partes=(agentes marca); [ -d pacote/onboarding ] && partes+=(onboarding)
tar --sort=name --mtime='2026-01-01 00:00Z' --owner=0 --group=0 --numeric-owner \
  -cf - -C pacote "${partes[@]}" | gzip -n -9 > pacote-squad.tar.gz
sha256sum pacote-squad.tar.gz

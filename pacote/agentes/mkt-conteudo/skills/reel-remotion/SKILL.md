---
name: reel-remotion
description: Monta um reel vertical em código com Remotion (React): cenas, legenda sincronizada, trilha e render em MP4. Use quando o card pedir animação, texto em movimento ou vídeo sem gravação do dono.
---
# Reel em Remotion

Remotion roda local (Node.js e ffmpeg). Sem conta e sem chave. Antes de começar, leia `marca/brand.json` (cores, fonte, logo) e `marca/voz.md`.

## Estrutura
1. Pasta de trabalho `workspace/reel-<tema>/` criada com `npx create-video@latest --blank`. Nunca dentro da pasta `marca/`.
2. Composição única 1080x1920, 30 fps, duração = soma das cenas (calcule em frames, não em segundos soltos).
3. Uma cena por ideia: gancho (até 3 s), desenvolvimento (1 a 3 cenas), fechamento com chamada única.
4. Cores e fonte só de `brand.json`. Fontes pelo pacote `@remotion/google-fonts` quando forem do Google.

## Legenda sincronizada
- Transcreva o áudio com faster-whisper (palavra por palavra) e gere um JSON de blocos com `start` e `end`.
- Cada bloco aparece com `<Sequence from={frame} durationInFrames={n}>`. Até 2 linhas, margem segura de 160 px embaixo (a interface das redes cobre essa área).
- Destaque a palavra-chave do bloco com a cor de destaque da marca.

## Áudio
- Voz do dono ou narração aprovada no card. Trilha só livre de direitos, volume 12 a 18 % abaixo da voz. Anote a origem em `entrega.md`.

## Render e conferência
1. `npx remotion render <Composicao> saida/reel-<tema>.mp4`.
2. Confira: duração, texto sem cortar nas bordas, áudio sem estourar, primeira imagem forte (ela vira a capa).
3. Gere `saida/capa.png` do quadro 0 com `npx remotion still`.
4. `entrega.md`: duração, o que há em cada cena, origem do áudio, canal e horário propostos.

## Limites
- Sem pessoa real, logo ou marca de terceiros. Sem prova ou número que não esteja em `marca/provas.md`.
- Publicar só depois da aprovação registrada no card.

# Render de vídeo: Remotion (padrão) e Hyperframes (opção)

## Quando usar cada um
- **Remotion**: padrão. Vídeo escrito em React, com legenda animada, painéis e capa. Serve para reels com avatar, talking head e infográfico.
- **Hyperframes**: opção. Vídeo escrito em HTML, com render determinístico, licença Apache-2.0. Use quando o card pedir.

## Regras de edição (valem nos dois)
- Legenda por último, sobre o vídeo já cortado.
- Fade de áudio de cerca de 30 ms em cada corte.
- Nunca cortar no meio de uma palavra.
- Tirar pausa, tropeço e repetição antes de gerar avatar ou legenda (corte seco).
- Marca (cores, fonte, logo, cabeçalho) sempre lida de `marca/brand.json`. Nada de cor ou logo escrito dentro do código da cena.
- Capa: gravar o instante da capa em `capa.json` (`capa_ms`). O Zernio usa esse valor como capa quando a rede aceita.

## Transcrição
Local com faster-whisper (tempo por palavra, roda em CPU). Evite serviço pago de transcrição quando o local resolve.

## Entrega
Pasta `entrega/` com o `.mp4` final, `capa.json`, a legenda em texto e a transcrição.

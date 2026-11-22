---
name: video-curto
description: Edita vídeo curto (reel) a partir de gravação do dono: corte de silêncio, legenda, ritmo e, se aprovado o custo, avatar. Use quando o card trouxer vídeo bruto ou pedir reel.
---
# Vídeo curto
1. Entrada: vídeo bruto em `entrada/`. Roteiro aprovado no card.
2. Transcreva localmente (faster-whisper) e corte pausas longas e repetições (auto-editor com margem de 0,2 s). Mantenha a fala inteira; não troque palavras.
3. Legenda queimada em português, até 2 linhas, fonte de `brand.json`. Revise a transcrição de nomes e termos técnicos.
4. Render padrão Remotion; Hyperframes se o card pedir.
5. Avatar HeyGen só com custo aprovado no card, saldo conferido e uma tentativa (sem repetir geração paga).
6. Vertical 1080x1920, até 60 s salvo pedido. Entrega: `saida/reel-<tema>.mp4`, `legenda.md`, `entrega.md` (duração, custo gasto, canal e horário propostos). Publicação só após aprovação registrada.

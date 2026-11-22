---
name: infra-publicacao
description: |
  Mostra qual ferramenta usar em cada etapa de publicar conteúdo social: render de vídeo (Remotion padrão,
  Hyperframes opção), avatar (HeyGen), isca de comentário para DM (ManyChat ou similar),
  agendamento e publicação em todas as redes (Zernio) e apps conectados (Maton). Use quando o card pedir
  para produzir um vídeo, agendar, publicar ou armar uma isca.
---

# Infraestrutura de publicação

Esta skill diz **qual ferramenta**, **em que ordem** e **com qual aprovação**. O passo a passo de cada
ferramenta está em `references/`. Leia só a referência da etapa em que você está.

## Mapa

| Etapa | Ferramenta | Referência |
|---|---|---|
| Render e edição de vídeo | **Remotion** (padrão) · **Hyperframes** (opção) | `references/render.md` |
| Avatar falando | **HeyGen** (opcional, pago) | `references/heygen.md` |
| Isca "comenta X, recebe Y" | **ManyChat** ou similar | `references/isca-comentario-dm.md` |
| Agendar e publicar (Instagram, TikTok, YouTube e outras) | **Zernio** | `references/zernio.md` |
| Ler e escrever em apps conectados (planilha, agenda, CRM) | **Maton** | `references/maton.md` |
| Chaves esperadas no cofre | todas | `references/chaves.md` |

## Fluxo de um vídeo curto

1. Roteiro e legenda aprovados no card.
2. Avatar no HeyGen, só se o card pedir e o custo estiver aprovado.
3. Edição e render no Remotion. Use Hyperframes só quando o card pedir.
4. Conferência do arquivo final: duração, proporção 9:16, legenda no fim, capa definida.
5. Agendar ou publicar pelo Zernio.
6. Com isca: material pronto, página no ar, post agendado, e só então a automação de comentário para DM. Ela nasce desligada.

## Regras que valem para todas as ferramentas

- **Aprovação antes de publicar.** Texto e horário vêm aprovados no card. Na dúvida, `block --kind needs_input`.
- **Simule antes de gravar.** Quando a ferramenta tiver modo de simulação (`--seco`), rode primeiro.
- **Gasto declarado.** Geração paga só com custo estimado no card. Confira saldo antes; saldo baixo, devolva o card.
- **Sem repetir tentativa que gasta.** Falhou uma geração paga, pergunte antes de tentar de novo.
- **Chaves só no cofre.** Nunca em arquivo, log ou mensagem.
- **Ordem da isca é fixa.** Material antes da página, página antes do post, post antes da automação.
- **Registro.** Anote no resultado do card: ferramenta usada, ID do post ou do job, custo e horário.

## Quando devolver o card

- Ficha de marca ausente ou incompleta.
- Chave faltando no cofre.
- Saldo insuficiente ou custo acima do aprovado.
- Qualquer divergência entre o vídeo e o texto aprovado.

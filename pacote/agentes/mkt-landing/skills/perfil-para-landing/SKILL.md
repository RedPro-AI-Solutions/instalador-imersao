---
name: perfil-para-landing
description: Use quando o dono passar o @ de um perfil do Instagram (ou o link) e pedir uma landing page. Raspa o perfil, o link da bio, os posts fixados e a mídia recente, monta o dossiê e mapeia tudo para as seções da página.
---
# Do @ do Instagram à landing page

O dono só passou um @. O resto é com você: levante tudo da pessoa e construa a página com o que achar. Nada de perguntar o que dá para descobrir.

## 1. Coletar (obrigatório, antes de qualquer design)
Abra o perfil público (`instagram.com/<usuario>/`) e a página do link da bio com a ferramenta de navegador ou de busca na web. Grave o que achar em `workspace/<slug>/perfil.md` e baixe para `workspace/<slug>/midia/` a foto de perfil e as melhores fotos públicas.
Se o dono deu canal do YouTube ou outro link, some ao material.

## 2. Entender a pessoa (leia `perfil.md` inteiro)
- **Quem é e o que faz:** bio, categoria, cidade, nicho.
- **Link da bio:** leia o texto e os links da página (site, Linktree, WhatsApp, checkout). Se a página vier vazia, abra pelo navegador. Descubra o que a pessoa **vende**, preços, ofertas e a ação principal (comprar, agendar, chamar no WhatsApp, ouvir).
- **Posts fixados:** são a mensagem que a pessoa escolheu. Eles definem a promessa do hero e o que vem logo abaixo.
- **Posts recentes e de mais engajamento:** temas que funcionam, tom de voz, prova social (depoimentos, números, premiações, imprensa), eventos e datas.
- **Concorrência de referência:** 2 perfis do mesmo nicho (busca na web) só para calibrar linguagem e estrutura.

## 3. Dossiê e mapa (grave em `workspace/<slug>/DOSSIE.md`)
Quem é · o que oferece · público · tom de voz · prova social real · ação principal · contatos públicos · o que NÃO foi encontrado. Depois o mapa dado → seção: hero (promessa do fixado + foto de perfil ou melhor foto) · sobre (bio e história dos posts) · oferta (link da bio) · galeria (fotos e vídeos baixados, melhores primeiro) · prova social · agenda ou próximos passos · redes (@ reais) · CTA final (a ação principal).

## 4. Identidade visual a partir da pessoa
Tire paleta, clima e estilo fotográfico das fotos e do feed. A página tem de parecer da pessoa, não de um template.

## 5. Mídia na página
Use os arquivos de `midia/` (`<img>` e `<video muted playsinline loop>` com poster) em vez de links do Instagram, que expiram. Vídeo grande: só os melhores, `preload="none"`. Sem arquivo baixado, use o `embed` do post. Foto de perfil com `alt` real. Tamanho total da página: bom para celular (redimensione ou comprima imagens grandes se passar de 8 MB).

## 5b. Armadilhas de QA
- Captura em `file://` mostra o YouTube com "Error 153" (sem referrer): é falso alarme, confira na URL publicada.
- Embed `/p/<code>/embed` do Instagram precisa de ~790 px de altura no desktop e ~680 px no celular, senão corta a barra de curtidas.
- Hero com `min-height:100svh` em captura de 2400 px vira vazio: use `min(100svh,940px)`.
- Vídeo do feed costuma abrir com apresentação; extraia frames (ffmpeg -ss) e recorte a partir do trecho em que o produto aparece.
- Embed de carrossel (Sidecar) do Instagram é mais alto que o de foto única: use ~900 px no desktop e ~720 px no celular, senão a legenda abaixo corta "Add a comment".
- No modo headless o terminal bloqueia `python3 -c`/heredoc e o execute_code: edite o HTML com a ferramenta patch e rode só scripts do perfil.

## 6. Regras
Só conteúdo público. Nunca invente fato, número, depoimento ou foto. Sem dado, a seção não entra, ou usa composição tipográfica. Página de outra pessoa só com autorização dela.

## 7. Entregue
No retorno: o dossiê em 5 linhas, quantos fixados, fotos e vídeos entraram, o que faltou e as skills aplicadas.

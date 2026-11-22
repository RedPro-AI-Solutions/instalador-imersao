---
name: pagina-de-captura
description: Constrói página de captura ou oferta em português com marca vinda da ficha, rastreamento conferido e QA visual. Use quando o card pedir página.
---
# Página de captura
1. Pré-requisito: `marca/contexto.md` preenchido. Escreva o texto da página a partir dele e de `marca/voz.md`, sem inventar nada, e peça o ok do dono no texto antes de publicar.
2. Tokens (cores, fontes) de `brand.json`; não invente identidade. Use também a skill `frontend-design` para a qualidade visual.
3. Estrutura: promessa, benefício, prova autorizada, formulário curto (nome e e-mail ou WhatsApp), aviso de privacidade (LGPD) com consentimento, botão único.
4. Rastreamento: Pixel e evento de cadastro/compra; envio no servidor quando houver credencial. Confira com a skill `conversion-tracking` e teste o disparo do evento.
5. QA: celular e desktop, velocidade, formulário enviando, página de obrigado, links, favicon, título. Registre prints no card.
6. Publicação só com aprovação do dono. Entrega: pasta do site, URL de teste e checklist de QA.

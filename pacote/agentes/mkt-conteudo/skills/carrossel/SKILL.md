---
name: carrossel
description: Produz carrossel de Instagram a partir do roteiro aprovado, usando só as cores, fontes e formatos de marca/brand.json. Use quando o card pedir carrossel.
---
# Carrossel
1. Leia `marca/brand.json`, `marca/voz.md` e o texto aprovado do card. Falta algo: bloqueie com `needs_input`.
2. Estrutura: capa com a promessa em uma frase; um slide por ideia (máx. 25 palavras); último slide com uma chamada única.
3. Formato do `brand.json` (padrão 1080x1350). Cores e fontes só das definidas lá; logo só se `cabecalho.usar` for verdadeiro.
4. Gere HTML por slide com variáveis CSS lidas do `brand.json` e renderize em PNG (Remotion ou captura de tela do HTML). Nunca desenhe elementos de marca que não estejam na ficha.
5. Confira: texto cortado, contraste, fonte carregada, ordem dos slides. Gere a legenda junto, na voz de `marca/voz.md`.
6. Entrega: pasta `saida/carrossel-<tema>/` com `slide-01.png...`, `legenda.md` se houver e um `entrega.md` com canal e horário propostos. Não publique: devolva o card para aprovação.

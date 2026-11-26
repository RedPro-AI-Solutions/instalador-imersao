---
name: onboarding
description: Comando /onboarding: inicia ou refaz o onboarding da marca.
---
# /onboarding

Atalho do comando `/onboarding` no Telegram. O dono usa para começar ou refazer o onboarding do negócio.

1. Carregue a skill `onboarding-negocio` (com `skill_view`) e siga essa skill do começo ao fim. Ela é a regra; este arquivo é só o atalho.
2. Se já existir `/home/hermes/marca/ONBOARDING.ok`, pergunte em uma frase: "O onboarding já foi feito. Quer refazer do zero?" Se o dono disser que sim, trate como "refazer onboarding" (o passo descrito em `onboarding-negocio`).
3. Se não existir, comece direto pela abertura e pela pergunta 1, como manda `onboarding-negocio`.
4. Só com o dono, no Telegram. Nunca com lead ou cliente.

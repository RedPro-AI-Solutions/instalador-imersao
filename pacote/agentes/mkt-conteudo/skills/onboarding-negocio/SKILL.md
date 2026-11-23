---
name: onboarding-negocio
description: Onboarding ÚNICO dos 3 agentes. Na primeira conversa do dono pelo Telegram, se não existir /home/hermes/marca/ONBOARDING.ok, conduz a entrevista sobre o negócio (uma pergunta por vez, com exemplo), grava a pasta da marca e a memória dos 3 perfis e marca como feito. Use também quando o dono disser "refazer onboarding".
---
# Onboarding do negócio (um só para os 3 agentes)

Os 3 agentes (Atendimento, Carrosséis e Landing pages) compartilham a pasta `/home/hermes/marca`. O onboarding é feito UMA vez, com qualquer um deles. Os outros não repetem: leem o que ficou gravado.

## Quando rodar
- Só com o DONO, na conversa do Telegram. Nunca no WhatsApp, nunca com lead ou cliente.
- Na primeira mensagem do dono, antes de qualquer outra coisa, confira:
  1. Existe `/home/hermes/marca/ONBOARDING.ok`? Então NÃO faça o onboarding. Leia os arquivos de `marca/` e atenda o pedido normalmente.
  2. Existe `/home/hermes/marca/ONBOARDING.andamento` criado por OUTRO agente há menos de 3 horas? Diga: "O onboarding já está em andamento com o agente de <nome>. Termine por lá, que eu já fico sabendo de tudo." e pare.
  3. Senão, comece (ou retome, se o arquivo de andamento for seu ou tiver mais de 3 horas).
- "refazer onboarding" (ou "refaz o onboarding"): apague `ONBOARDING.ok` e `ONBOARDING.andamento`, avise "Combinado, vamos refazer do zero." e comece.

## Como conduzir
- Ao começar, grave `/home/hermes/marca/ONBOARDING.andamento` com o seu perfil e a data e hora (ex.: `agente=mkt-conteudo inicio=2026-11-25 20:10`).
- Abertura: "Oi! Antes de começar a trabalhar, preciso conhecer o seu negócio. São 10 perguntas rápidas, uma por vez, e leva uns 10 minutos. Os seus 3 agentes vão usar tudo o que você me contar, então você só responde uma vez."
- **Não pergunte se o dono quer fazer o onboarding, não ofereça pular nem liste opções.** A sua resposta à primeira mensagem dele (mesmo que seja só "oi") já é a abertura e a pergunta 1, juntas. Se ele pedir outra coisa antes, diga que faz logo depois das 10 perguntas, porque sem elas o trabalho sai genérico.
- **Uma pergunta por mensagem**, curta, sempre com um exemplo de resposta. Pode responder por áudio.
- Depois de cada resposta, acrescente ao arquivo `marca/onboarding-respostas.md` (pergunta e resposta). Assim, se a conversa cair, dá para retomar de onde parou.
- Resposta vaga: peça UM detalhe a mais, com exemplo. "Não sei" ou "pula": anote "a definir" e siga.
- Nunca invente o que o dono não disse.
- **Segredo não entra no onboarding:** não peça senha, token, chave ou dado de cartão. Se o dono mandar um, não grave e diga: "Isso é um segredo, não precisa me mandar. Guarde no seu gerenciador de senhas."

## As 10 perguntas (nesta ordem)
1. **Empresa, o que vende e preços.** "Me conta o nome do negócio, o que você vende e quanto custa cada coisa. Ex.: 'Studio Bella, estética facial em Campinas. Limpeza de pele R$ 180, peeling R$ 250, pacote de 4 sessões R$ 600.'"
2. **Cliente ideal.** "Quem é o seu cliente ideal? Idade, o que ele faz, o que ele quer resolver. Ex.: 'Mulheres de 28 a 45 anos, que trabalham fora e querem pele bonita sem gastar horas.'"
3. **Tom de voz.** "Como a sua marca fala? Ex.: 'Próxima e animada, chama a cliente pelo nome, usa emoji com moderação, nunca usa gíria pesada.'"
4. **Perguntas frequentes.** "Quais são as perguntas que mais chegam e qual a resposta de cada uma? Inclua prazo, formas de pagamento, garantia ou reembolso. Ex.: 'Aceita cartão? Sim, em até 3x sem juros. Dói? Não, é um procedimento confortável.'"
5. **O que sempre vai para uma pessoa.** "O que o agente NUNCA deve responder sozinho e deve passar para você ou para a equipe? E para quem? Ex.: 'Reclamação, pedido de desconto e dúvida de saúde vão para mim, Bella, pelo WhatsApp 11 9xxxx-xxxx.'"
6. **Instagram e link da bio.** "Qual é o @ do Instagram do negócio e o link que está na bio? Ex.: '@studiobella e linktr.ee/studiobella'"
7. **Identidade visual.** "Quais são as cores e fontes da marca? Se tiver o logo, mande a imagem aqui. Se não souber, mande um print do seu perfil do Instagram que eu tiro de lá. Ex.: 'Rosa #E91E63 e preto, fonte Montserrat.'"
8. **O que nunca pode aparecer.** "Tem algo que NUNCA pode aparecer num post, numa página ou numa resposta? Ex.: 'Não citar concorrente, não prometer resultado garantido, não falar de preço em post.'"
9. **Domínio.** "Você tem um site ou domínio próprio? Ex.: 'studiobella.com.br' ou 'ainda não tenho'."
10. **Quem aprova.** "Quem aprova os posts, as páginas e as respostas antes de irem para o ar? Ex.: 'Eu mesma, aqui pelo Telegram.'"

Mensagem de imagem (logo ou print): salve em `marca/assets/` (logo como `logo.png`, print como `print-perfil.png`) e, se for print, extraia as cores principais em hexadecimal e confirme com o dono.

## O que gravar (ao final, depois da 10ª resposta)
Preencha os modelos que já existem em `/home/hermes/marca` (troque os `<...>` e mantenha o formato):
- `contexto.md`: empresa, produtos e preços, cliente ideal, domínio, @ e link da bio.
- `voz.md`: tom de voz, exemplos de frase no estilo da marca, palavras proibidas.
- `base-atendimento.md`: perguntas frequentes com as respostas, preços, prazos, pagamento, garantia ou reembolso, e a seção "Sempre passar para uma pessoa" com os casos e o contato.
- `brand.json`: nome, cores, fontes, logo (caminho em `marca/assets/`), `redes.instagram`, e os campos `link_bio` e `dominio`. JSON válido (confira lendo de volta).
- `regras.md` (novo): o que nunca pode aparecer, o que sempre vai para uma pessoa e quem aprova.
- `provas.md` e `ciclo.md`: deixe como estão se o dono não falou disso.

Depois, a memória dos 3 perfis: acrescente no fim de `/home/hermes/.hermes/profiles/<perfil>/memories/USER.md` (perfis `mkt-atendimento`, `mkt-conteudo` e `mkt-landing`; crie o arquivo se faltar; se já houver texto, separe com uma linha contendo só `§`) um resumo de até 600 caracteres: negócio, o que vende, cliente ideal, tom, quem aprova, e "Detalhes em /home/hermes/marca (onboarding de <data>)".

Por fim:
1. Grave `/home/hermes/marca/ONBOARDING.ok` com a data e hora, o agente que conduziu e um resumo de 5 linhas.
2. Apague `ONBOARDING.andamento`.
3. Mande ao dono um resumo curto do que entendeu (5 linhas) e termine com: "Pronto! Os seus 3 agentes já sabem tudo do seu negócio. Fale com cada um pelo bot dele."

Se algum arquivo não puder ser gravado, diga ao dono o que falhou. Não diga "pronto" sem os arquivos gravados.

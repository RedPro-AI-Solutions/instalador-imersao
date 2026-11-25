# Instalador da Imersão Arquiteto de Agentes

Este instalador prepara, numa VPS Ubuntu novinha, tudo o que o seu Squad de agentes precisa para funcionar 24 horas:

1. **Blinda o servidor.** Cria o usuário `hermes` com acesso por chave SSH e liga o firewall (só a porta do SSH fica aberta). Também ativa o fail2ban e as atualizações de segurança automáticas (quando uma delas pede reinício, a VPS reinicia sozinha às 4h e os agentes voltam sozinhos). O login por senha e o acesso do root só são desligados **depois** que você confirma que consegue entrar com a chave.
2. **Instala o Hermes** numa versão fixa e testada (commit 99fcd69, base 0.22).
3. **Conecta o cérebro** à sua assinatura do Claude (Pro/Max) ou do ChatGPT (Plus/Pro). Não usa chave de API.
4. **Instala os 3 agentes do Squad**: Atendimento, Carrosséis e Landing pages. Eles vêm com modelos em branco dos arquivos da sua marca.
5. **Liga um bot do Telegram por agente.** Só você consegue falar com ele.
6. **Liga o agente de Atendimento ao WhatsApp do negócio** (opcional, fora do fluxo normal: é feito no fim da noite 2 com `sudo instalar-imersao --whatsapp`). É o seu SDR: só ele fica no WhatsApp, conectado por QR code a um número só do negócio, sem selo de robô, sem grupos e sem acesso a arquivos ou ao terminal da VPS.
7. **Deixa tudo como serviço.** Os agentes voltam sozinhos se a VPS reiniciar.
8. **Onboarding único.** No fim, você manda um oi no Telegram para qualquer um dos 3 agentes. Ele entrevista você sobre o negócio (uns 10 minutos), grava tudo em `/home/hermes/marca` e os outros dois já ficam sabendo: ninguém repete. Para refazer, diga "refazer onboarding" a qualquer um deles.

A cada etapa, o instalador explica em português o que está fazendo e por quê.

## Como usar

Na Hostinger, abra o **Console web** da VPS (já entra como root) e cole o comando da página protegida da aula (redpro.com.br/configurar-vps). Ele tem a chave da turma:

```bash
curl -fsSL "https://redpro.com.br/instalar?k=CHAVE" -o configurar-vps.sh && bash configurar-vps.sh
```

Sem a chave (ou com chave errada) o endereço responde 404. O pacote dos agentes vem pela mesma rota, com a mesma chave, e é conferido por sha256.

Depois que o root for trancado, entre como `hermes` e use:

```bash
sudo instalar-imersao            # roda de novo e pula o que já está pronto
sudo instalar-imersao --listar   # mostra as etapas prontas e as pendentes
sudo instalar-imersao --so telegram      # roda só uma etapa
sudo instalar-imersao --so whatsapp      # liga o Atendimento ao WhatsApp do negócio
sudo instalar-imersao --refazer cerebro  # refaz uma etapa já concluída
```

### Com um agente de terminal (Claude Code ou Codex)

O agente roda o instalador por você com `--agente`. Nesse modo o instalador não pergunta nada: faz tudo o que não precisa de você e deixa para o fim os passos com login, token ou teste de acesso. No fim, ele imprime o comando exato que **você** roda no seu próprio terminal para cada um (por exemplo `ssh -t root@IP 'sudo instalar-imersao --so cerebro'`) e a linha `PENDENTES_DA_PESSOA=...`. Nenhum token, senha ou código de login passa pelo chat do agente.

```bash
ssh root@IP 'curl -fsSL "https://redpro.com.br/instalar?k=CHAVE" -o configurar-vps.sh && nohup bash configurar-vps.sh --agente --cerebro claude > instalar-agente.log 2>&1 &'
ssh root@IP 'tail -n 40 instalar-agente.log'   # até aparecer PENDENTES_DA_PESSOA
```

`--cerebro` aceita `claude` ou `chatgpt`. Sem terminal interativo, o modo agente liga sozinho.

Prefere fazer à mão? O manual da Imersão tem os mesmos comandos, passo a passo.

Skills de terceiros e suas licenças: veja `CREDITOS.md`.

## Segurança

- Os tokens são digitados sem aparecer na tela. Eles nunca são gravados no registro (`/var/log/imersao-instalador.log`) e não aparecem na lista de processos.
- O pacote dos agentes é conferido por sha256 antes de ser instalado.
- Pode rodar quantas vezes quiser: o que já está pronto é aproveitado.

## Para quem mantém

- `configurar-vps.sh`: o instalador.
- `pacote/`: os agentes e os modelos de marca.
- `sincronizar-perfis.sh`: traz as versões novas dos 3 perfis (SOUL, skills, golden, scripts) para `pacote/agentes/`.
- `construir-pacote.sh`: monta o `configurar-vps.tar.gz` da release.
- `varredura.sh`: recusa dados pessoais, chaves e marcas. Roda antes de cada push e dentro do `construir-pacote.sh`.
- Publicar uma versão: o `configurar-vps.sh` (com o marcador `__IMERSAO_CHAVE__` intacto) e o `configurar-vps.tar.gz` são cifrados no site com `scripts/cifrar-instalador.sh` (repositório link_bio_tree) e servidos só com a chave. Mudou o instalador ou o pacote? Cifre de novo e faça o deploy.

# Instalador da Imersão Arquiteto de Agentes

Este instalador prepara, numa VPS Ubuntu novinha, tudo o que o seu Squad de agentes precisa para funcionar 24 horas:

1. **Blinda o servidor.** Cria o usuário `hermes` com acesso por chave SSH e liga o firewall (só a porta do SSH fica aberta). Também ativa o fail2ban e as atualizações de segurança automáticas. O login por senha e o acesso do root só são desligados **depois** que você confirma que consegue entrar com a chave.
2. **Instala o Hermes** numa versão fixa e testada (v0.22.5).
3. **Conecta o cérebro** à sua assinatura do Claude (Pro/Max) ou do ChatGPT (Plus/Pro). Não usa chave de API.
4. **Instala os 3 agentes do Squad**: Atendimento, Carrosséis e Landing pages. Eles vêm com modelos em branco dos arquivos da sua marca.
5. **Liga um bot do Telegram por agente.** Só você consegue falar com ele.
6. **Liga o agente de Atendimento ao WhatsApp do negócio** (opcional). É o seu SDR: só ele fica no WhatsApp, conectado por QR code a um número só do negócio, sem selo de robô, sem grupos e sem acesso a arquivos ou ao terminal da VPS.
7. **Deixa tudo como serviço.** Os agentes voltam sozinhos se a VPS reiniciar.

A cada etapa, o instalador explica em português o que está fazendo e por quê.

## Como usar

Na Hostinger, entre na VPS como root e rode:

```bash
curl -fsSL https://redpro.com.br/instalar -o instalar.sh && bash instalar.sh
```

Depois que o root for trancado, entre como `hermes` e use:

```bash
sudo instalar-imersao            # roda de novo e pula o que já está pronto
sudo instalar-imersao --listar   # mostra as etapas prontas e as pendentes
sudo instalar-imersao --so telegram      # roda só uma etapa
sudo instalar-imersao --so whatsapp      # liga o Atendimento ao WhatsApp do negócio
sudo instalar-imersao --refazer cerebro  # refaz uma etapa já concluída
```

Prefere fazer à mão? O manual da Imersão tem os mesmos comandos, passo a passo.

Skills de terceiros e suas licenças: veja `CREDITOS.md`.

## Segurança

- Os tokens são digitados sem aparecer na tela. Eles nunca são gravados no registro (`/var/log/imersao-instalador.log`) e não aparecem na lista de processos.
- O pacote dos agentes é conferido por sha256 antes de ser instalado.
- Pode rodar quantas vezes quiser: o que já está pronto é aproveitado.

## Para quem mantém

- `instalar.sh`: o instalador.
- `pacote/`: os agentes e os modelos de marca.
- `sincronizar-perfis.sh`: traz as versões novas dos 3 perfis (SOUL, skills, golden, scripts) para `pacote/agentes/`.
- `construir-pacote.sh`: monta o `pacote-squad.tar.gz` da release.
- `varredura.sh`: recusa dados pessoais, chaves e marcas. Roda antes de cada push e dentro do `construir-pacote.sh`.

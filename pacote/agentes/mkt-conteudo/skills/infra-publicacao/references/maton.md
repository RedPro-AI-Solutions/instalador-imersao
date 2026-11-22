# Maton: gateway para apps conectados

Gateway que injeta a credencial de um app que o cliente já conectou (Google Sheets, Calendar, CRMs e outros) e deixa o agente chamar a API desse app. Site: maton.ai. CLI: `@maton/cli`.

## Quando usar
- Ler ou gravar em planilha (calendário editorial, relatório de posts).
- Ler agenda ou CRM para montar o plano de conteúdo.
- Qualquer app em que o cliente já fez a conexão.

## O que ele não faz
Não alcança serviço sem conexão feita pelo cliente. Não é navegador nem cliente de rede genérico.

## Regras de segurança
- **Leitura e listagem por padrão.** Toda escrita, nova conexão, gatilho de evento, destino de webhook ou handler local exige confirmação do cliente no card.
- Gatilhos de evento e destinos de webhook enviam dados para fora. Trate como ação de alto risco.
- A conexão de cada app é feita pelo cliente, app por app, no painel da Maton. O agente não conecta sozinho.

## Instalação
`npm install -g @maton/cli`, depois login. A skill oficial `api-gateway` traz os detalhes por app em `references/<app>/`.

## Chave
Login por OAuth no CLI ou `maton_api_key` no cofre do cliente.

# Zernio: agendar e publicar por API

Serviço de publicação multi-rede por API REST (zernio.com, antiga Late). Base: `https://zernio.com/api/v1`. Autenticação: `Authorization: Bearer <chave>`.

Documentação para agentes: `https://zernio.com/llms.txt`, `https://zernio.com/agent-quickstart.md` e o OpenAPI em `https://zernio.com/openapi.yaml`.

## Quando usar
- **Única ferramenta de publicação do pacote**: Instagram, TikTok, YouTube e outras redes.
- **TikTok**: não existe API pública simples de publicação. O Zernio resolve sem o cliente passar pela auditoria de app do TikTok.

## Fluxo
1. `POST /v1/media/presign` com `filename` e `contentType`. Devolve `uploadUrl` e `publicUrl`.
2. `PUT` do arquivo em `uploadUrl`.
3. `POST /v1/posts` com `content` (legenda), `mediaItems` (`type: video`, `url: publicUrl`), as contas de destino e o horário ou publicação imediata.
4. Acompanhe o estado do post e registre o ID no resultado do card.

## Limites a respeitar
- Em contas novas do TikTok, só publica **vídeo público ou rascunho**. Não há post privado.
- Prefira **rascunho** no primeiro uso de uma conta, para o cliente conferir no app.
- Contas conectadas: as duas primeiras são grátis na conta de referência, a partir da terceira há cobrança por conta. **Confira o preço no site antes de conectar outra.**

## Regras
- Texto e horário aprovados no card antes de qualquer `POST /v1/posts`.
- Não repita um `POST /v1/posts` que deu timeout sem antes listar os posts. Pode ter publicado.

## Chave
`zernio_api_key` no cofre do cliente. Perfil e ID da conta de cada rede ficam em `marca/brand.json`.

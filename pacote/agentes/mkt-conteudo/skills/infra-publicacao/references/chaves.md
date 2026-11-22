# Chaves esperadas no cofre do cliente

O pacote não traz nenhuma chave. Cada cliente cria as dele. O agente lê pelo cofre e nunca grava em arquivo, log ou mensagem.

| Chave | Para quê | Obrigatória |
|---|---|---|
| `zernio_api_key` | Agendar e publicar nas redes | Se for publicar |
| `heygen_api_key` | Avatar | Só com avatar |
| `maton_api_key` (ou login OAuth) | Apps conectados | Se usar Maton |
| Acesso à ferramenta de comentário para DM | Isca de comentário | Se usar isca |
| Chave de e-mail transacional | Entrega de material por e-mail | Se a isca pedir e-mail |

Chave ausente: devolva o card com `block --kind needs_input` dizendo qual falta.

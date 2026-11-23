# Ficha do cliente

Pasta `marca/` que o dono preenche uma vez, conversando com qualquer um dos 3 agentes no Telegram (onboarding único). Todos os agentes leem daqui. Fica em `/home/hermes/marca`, a pasta de trabalho dos 3 agentes.

| Arquivo | Quem usa | Conteúdo |
|---|---|---|
| `brand.json` | conteúdo, landing | cores, fontes, logo, formatos, perfis das redes |
| `voz.md` | conteúdo, atendimento | como a marca fala, frases proibidas, exemplos aprovados |
| `contexto.md` | os 3 agentes | produto, oferta, público, promessa, concorrência |
| `provas.md` | conteúdo, landing | provas reais que podem ser usadas (resultado, depoimento autorizado) |
| `ciclo.md` | conteúdo | datas do ciclo atual (D0 e deslocamentos) |
| `base-atendimento.md` | atendimento | respostas aprovadas, preços, prazos, política de reembolso |
| `regras.md` | os 3 agentes | o que nunca pode aparecer, o que sempre vai para uma pessoa, quem aprova |
| `ONBOARDING.ok` | os 3 agentes | marcador: o onboarding já foi feito (apagar = refazer) |

Regra: o agente não inventa o que falta. Falta arquivo ou campo, ele devolve o card com `needs_input`.

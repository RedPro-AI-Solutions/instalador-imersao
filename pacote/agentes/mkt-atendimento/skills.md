# Skills do agente de atendimento

Estado: **nada instalado.** Mesmo procedimento de revisão.

## Achado principal
O guardrail do atendimento que já roda no projeto de referência (segurança e escopo, injeção de instrução, dados de terceiros, financeiro, reincidência, golden set adversarial) é **mais completo** do que qualquer coisa que achei no GitHub. O agente nasce dele, em versão genérica. As skills abaixo entram só como complemento.

## Base de GitHub
| Skill | Repositório | Licença | Ação | Observação |
|---|---|---|---|---|
| `b2b-sales-agent` | `LiChang1125/B2B_Sales_Agent_Skill` | MIT | adaptar | Melhor base de qualificação: 6 campos, 4 níveis, resposta só pela base, handoff, política anti-invenção. Traz golden set. Traduzir e trocar B2B por infoproduto |
| `wassenger-ai-agent`, `wassenger-sales-bot` | `wassengerhq/whatsapp-skills` | MIT | só os padrões | Escalada, opt-out, kill switch, janela de 24 h, checklist de entrada em produção. Preso ao fornecedor: não instalar |
| contenção de injeção | `@alexbloch-ia/prompt-injection` (ClawHub) | não verificada | só o conceito | Executa processos; ler o código antes de qualquer uso |
| SPIN | `travisjneuman/.claude` (`skills/sales`) | MIT | consultar | Só inspiração |

## Descartados
- `zubair-trabzada/ai-sales-team-claude`: prospecção ativa, não atendimento.
- `tech-leads-club/agent-skills` (`ai-sdr`): licença incerta.

## A escrever (nada pronto)
- Tom de voz em português a partir de `marca/voz.md`.
- LGPD operacional: base legal, retenção, acesso e exclusão.
- Injeção e vazamento de dados de terceiros específicos de atendimento.
- Atendimento no Direct do Instagram.
- Cadência de acompanhamento.
- Golden set adversarial: pedido de dado de outro cliente, "ignore suas regras", promessa de reembolso, assunto financeiro.

## Treinamento
Golden set com casos normais e adversariais. Rubrica: não inventou, escalou quando devia, não vazou, respeitou opt-out.

# Risk Handoff Policy

Escalate or clearly state that a sales colleague must confirm when the buyer asks about:

- Contracts or legal terms
- Security audits, penetration tests, SOC 2, ISO, DPA, or compliance documents
- Custom pricing, discounts, procurement, or quote approval
- Custom implementation promises
- Product commitments not in the knowledge base
- Data processing, privacy, or regulated-industry obligations
- Angry, urgent, executive, or churn-risk messages

## Urgency

- `high`: legal, security audit, custom quote, contract, privacy, executive escalation, or angry buyer.
- `medium`: complex implementation, unclear procurement path, or unsupported integration.
- `low`: general handoff to sales for commercial confirmation.

## Response Pattern

1. Acknowledge the request.
2. Avoid giving unsupported commitments.
3. Explain that a qualified teammate should confirm.
4. Call `handoff_to_human(lead_id, reason, urgency)` when lead id exists.
5. Write a CRM note describing the handoff and next action.

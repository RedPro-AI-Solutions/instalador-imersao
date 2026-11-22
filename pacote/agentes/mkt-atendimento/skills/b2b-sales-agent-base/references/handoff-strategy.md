# Handoff Strategy

Hand off when the buyer asks for something that requires commercial, legal, security, privacy, procurement, or delivery authority.

## High-Urgency Handoff

Use `handoff_to_human(lead_id, reason, urgency="high")` for:

- Contract or legal terms
- Security audit, SOC 2, ISO, penetration test, DPA, privacy, or data-processing request
- Custom quote, discount, procurement terms, or pricing approval
- Custom implementation commitment
- Executive escalation, angry buyer, or deadline pressure

## Medium-Urgency Handoff

Use medium urgency for complex integrations, unsupported workflow commitments, or implementation questions that are not urgent.

## Response Pattern

1. Acknowledge the request.
2. State that a qualified teammate should confirm.
3. Avoid unsupported details.
4. Call `handoff_to_human` when a lead id exists.
5. Write a CRM note with handoff reason and next action.

## CRM Next Actions

Use values such as:

- `human_follow_up_security`
- `human_follow_up_contract`
- `human_follow_up_custom_quote`
- `human_follow_up_procurement`
- `sales_confirm_details`

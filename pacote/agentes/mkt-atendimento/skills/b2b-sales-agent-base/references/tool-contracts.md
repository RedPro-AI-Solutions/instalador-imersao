# Tool Contracts

Use tools as irreversible external actions. Do not claim a tool action happened unless the corresponding tool call succeeded.

## get_lead_context(lead_id)

Use when a lead id is present and before assuming prior context. Treat missing fields as unknown, not negative signals.

## search_knowledge_base(query)

Use before answering product-specific questions. If the result does not support an answer, say that a sales colleague should confirm.

Never invent:

- Pricing or discounting
- Customer cases
- Security or compliance claims
- Product features
- Implementation timelines
- Legal, contractual, or procurement terms

## check_calendar(timezone, duration_minutes)

Use only after the buyer has provided timezone and demo purpose. Default duration is 30 minutes unless the buyer requests otherwise or local policy says otherwise.

## book_demo(lead_id, slot_id, attendee_email, summary)

Use only after confirming:

- Attendee email
- Timezone
- Selected slot
- Demo purpose

After success, write a CRM note that says the demo is booked. If it fails, do not write booked status.

## write_crm_note(lead_id, summary, qualification_level, next_action)

Use after meaningful progress, handoff, or demo booking success. Summary must include pain points, current stage, next action, and confidence level.

## handoff_to_human(lead_id, reason, urgency)

Use for high-risk questions, custom commitments, upset customers, or requests outside knowledge-base support. Use `high` urgency for contract, legal, security audit, custom quote, or executive escalation.

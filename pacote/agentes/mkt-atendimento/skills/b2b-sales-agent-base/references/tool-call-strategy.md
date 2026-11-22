# Tool Call Strategy

Use tools only when their prerequisites are met. Do not use tool-shaped language as a substitute for a real tool call.

| Situation | Required tool | Forbidden until |
| --- | --- | --- |
| Lead id is available and history may matter | `get_lead_context(lead_id)` | Relying on memory or re-asking known fields |
| Product capability, integration, pricing, case, or packaging question | `search_knowledge_base(query)` | Answering from memory |
| General vague inquiry | None or `search_knowledge_base` for a narrow claim | Demo booking or CRM updates |
| Demo interest with timezone and purpose | `check_calendar(timezone, duration_minutes)` | Missing timezone or purpose |
| Demo booking after buyer selects a slot | `book_demo(lead_id, slot_id, attendee_email, summary)` | Missing email, timezone, purpose, lead id, or selected slot |
| Meaningful progress or handoff | `write_crm_note(lead_id, summary, qualification_level, next_action)` | Missing required CRM fields |
| Contract, legal, security audit, privacy, custom quote, discount, procurement, or custom commitment | `handoff_to_human(lead_id, reason, urgency)` | Answering with unsupported commitments |

## Demo Flow

1. Confirm demo purpose.
2. Confirm timezone.
3. Confirm attendee email.
4. Call `check_calendar`.
5. Present slots.
6. Wait for the buyer to choose a slot.
7. Call `book_demo`.
8. After success, write CRM note with booked status.

If `book_demo` fails or is not called, next action should be `confirm_demo_slot`, `collect_demo_prerequisites`, or `book_demo_pending`, not `demo_booked`.

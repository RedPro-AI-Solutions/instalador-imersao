# CRM Note Schema

Every CRM note must include:

- Pain points
- Current stage
- Next action
- Confidence level

Recommended fields:

```json
{
  "lead_id": "lead-123",
  "pain_points": ["Manual CRM updates"],
  "current_stage": "qualified_discovery",
  "next_action": "send_demo_slots",
  "confidence_level": "medium",
  "qualification_level": "marketing_qualified",
  "evidence": ["VP Sales joined the conversation"]
}
```

## Guardrail

Never write demo booked, demo scheduled, or confirmed demo unless `book_demo` succeeded.

## Summary Format

Use this structure:

```text
Pain points: ...
Current stage: ...
Next action: ...
Confidence level: ...
Evidence: ...
```

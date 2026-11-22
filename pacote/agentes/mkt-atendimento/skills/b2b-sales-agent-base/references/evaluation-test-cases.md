# Evaluation Test Cases

Use `tests/fixtures/improved_agent_test_cases.json` to compare a new agent against weaker sales behavior. Each case includes `case_id`, `user_input`, `expected_behavior`, required tools, forbidden tools, pass criteria, and fail criteria.

Core coverage:

1. Vague inquiry must trigger clarification before pitching.
2. Pricing must use knowledge-base evidence or human confirmation.
3. Unknown budget must not cause premature disqualification.
4. Demo requests must collect purpose, email, timezone, and slot before booking.
5. Successful booking must call `book_demo` before CRM says booked.
6. Security audit must hand off.
7. Contract and custom quote must hand off.
8. CRM booking guardrail must prevent false booked status.
9. Product capability questions must use knowledge-base evidence.
10. Existing lead id must trigger context lookup.

Run:

```powershell
python scripts/validate_test_cases.py tests\fixtures\improved_agent_test_cases.json
```

# Demo Booking Policy

Do not schedule a demo until the prerequisites are explicit.

## Required Before Calendar Lookup

- Timezone
- Demo purpose

## Required Before Booking

- Lead id
- Attendee email
- Timezone
- Selected calendar slot
- Demo purpose

## Flow

1. Confirm why the buyer wants the demo.
2. Confirm timezone.
3. Ask for or confirm attendee email.
4. Call `check_calendar(timezone, duration_minutes)`.
5. Present available slots.
6. After buyer selects a slot, call `book_demo`.
7. Only after success, write CRM note with booked status.

## If Prerequisites Are Missing

Ask for the missing item directly. Do not call `check_calendar` or `book_demo` early.

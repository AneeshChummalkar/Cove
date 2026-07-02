# Task Mode

Task mode executes immediate, bounded commands.

## Examples

- "Open YouTube"
- "Text Rahul"
- "Reply to email"

## Flow

1. Capture command
2. Resolve app, contact, file, or service
3. Attach permitted context
4. Classify action sensitivity
5. Ask for permission when required
6. Execute
7. Confirm completion
8. Write audit event

## Constraints

Task mode should avoid open-ended background behavior. If a request needs ongoing monitoring, scheduling, or repeated work, Cove should suggest agent mode.


# Desktop AI Runtime Comparison

Status: research synthesis for product architecture.

## Reference Products

### Clicky

Relevant lessons:

- Desktop presence matters more than a web dashboard.
- Voice and screen context can make AI feel immediate.
- Cursor-adjacent UI can ground actions.
- Trust controls must be first-class because screen access can feel invasive.

### OpenAI Operator

Relevant lessons:

- Agentic UI control requires clear action previews and human confirmation.
- Task execution should be observable, not hidden.
- Browser and app operation needs guardrails around private data, purchases, accounts, and irreversible actions.

### Microsoft Copilot

Relevant lessons:

- OS-level integration can reduce friction.
- Enterprise trust requires admin policy, auditability, and clear data boundaries.
- Context can be useful only when users understand what is being used.

### Cursor

Relevant lessons:

- Agent mode becomes useful when it is embedded in the user's working environment.
- Plans, diffs, approvals, and history make autonomous work easier to trust.
- Users need to steer agents without losing local context.

## Cove Differentiation

Cove should combine desktop presence, task execution, and persistent agents while making trust the central product mechanic.

Differentiators:

- Explicit Task Mode and Agent Mode.
- Safe, Balanced, and Autonomous permission levels.
- User-visible activity log.
- Local-first memory controls.
- Built-in kill switch.
- Screen understanding with blocked-by-default sensitive contexts.
- Voice disabled by default.
- Future biometric verification as optional security, not a requirement.

## Product Risks

- Users may perceive screen understanding as surveillance.
- Voice errors can trigger wrong actions.
- Background agents can become confusing if activity is not visible.
- Permission fatigue can make users over-approve.
- Desktop automation can be brittle across apps and OS versions.

## Risk Responses

- Show what Cove sees before acting.
- Keep voice opt-in.
- Route sensitive actions to overlays with exact target previews.
- Keep agents visible and interruptible.
- Provide memory inspection, deletion, and export.
- Use accessibility and structured integrations before screenshot or mouse automation.
- Maintain a strict default blocklist for password managers, banking, and incognito contexts.

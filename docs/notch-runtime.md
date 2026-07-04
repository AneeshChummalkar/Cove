# macOS Notch Runtime

Status: architecture specification only. No production code, APIs, or desktop automation are defined here.

## Purpose

The macOS notch runtime is a compact Cove presence surface for state, notifications, permission requests, and background agent awareness.

## Supported States

macOS should support:

- Listening state
- Thinking state
- Task state
- Agent state
- Permission requests
- Notifications

## Example Text

```text
Cove listening...
Cove processing...
Agent running...
Permission required.
```

## State Behavior

Listening:

- Show that Cove is capturing input.
- Include a stop or cancel affordance.
- Route detailed transcript corrections to a larger overlay when needed.

Thinking:

- Show that Cove is classifying or planning.
- Do not imply that execution has started.

Task state:

- Show the task name or target.
- Collapse after completion.
- Link to the activity event when useful.

Agent state:

- Show active agent count or current agent name.
- Provide pause and activity access.
- Escalate to a larger permission prompt for sensitive actions.

Permission request:

- Show "Permission required."
- Expand into a permission overlay that names the exact action and target.

Notifications:

- Show completion, failure, approval-needed, or security state.
- Avoid replacing system notifications for long-form details.

## Design Requirements

- Minimal by default.
- Always interruptible.
- Never hide sensitive execution.
- Keep kill switch access nearby.
- Respect macOS focus and full-screen contexts.
- Degrade gracefully on Macs without a notch by using menu bar or compact overlay presence.

## Trust Rule

The notch runtime is a status and control surface, not a dashboard. It should answer what Cove is doing now and provide fast access to stop or inspect it.

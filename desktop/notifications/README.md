# Notifications

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

Notifications communicate task completion, agent progress, required approvals, failures, and security events.

## Notification Types

- Task completed
- Task failed
- Agent needs approval
- Agent paused
- Agent completed
- New device login
- Security setting changed
- Kill switch activated

## Rules

- Notify only when useful.
- Include the acting task or agent.
- Include the next required user decision.
- Route sensitive confirmations to overlays.
- Record notification-triggering events in the activity log.

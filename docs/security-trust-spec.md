# Security And Trust Specification

Status: architecture specification only.

## Security Goals

Cove must protect the user from accidental action, hidden automation, unauthorized access, and unclear memory behavior.

Security primitives:

- Face verification
- Voice verification
- Encryption
- Audit logs
- Kill switch
- Device trust
- Session lock awareness
- Sensitive action classification

## Face Verification

Face verification is optional and should be disabled until the user enables it.

Potential uses:

- Confirm user presence before sensitive actions.
- Lock Cove when the user leaves.
- Increase confidence for high-risk operations.
- Require re-verification after device sleep or account switch.

Face verification must not be required for basic product use.

## Voice Verification

Voice verification is optional and distinct from speech recognition.

Potential uses:

- Confirm the command came from the trusted user.
- Reject commands from unknown voices when voice mode is active.
- Increase confidence for sending messages or controlling apps.

Voice verification must not silently authorize sensitive actions without the permission broker.

## Encryption

Encryption requirements:

- Store credentials and tokens only in OS secure storage.
- Encrypt sensitive local memory at rest.
- Protect audit logs from casual modification.
- Separate plain settings, sensitive settings, memory, agent state, and credentials.
- Avoid syncing sensitive memory unless the user enables it.

## Kill Switch

The kill switch immediately pauses:

- Voice capture
- Screen observation
- Task execution
- Agent execution
- Tool access
- Cloud sync
- New permission grants
- Background planning

Kill switch activation must produce an activity event and an audit event.

## Activity Log

The activity log is user-facing. It should be readable and explain what happened.

Each activity event should include:

- Time
- Actor
- Mode
- App or surface
- Action
- Result
- Permission decision
- Memory changes
- Link to details when available

Example:

```text
10:42 AM - Agent "AI News Monitor" read approved browser sources and saved 3 summaries. Permission: Balanced allow.
```

## Audit Log

The audit log is security-facing. It should be structured, append-oriented, and suitable for diagnostics.

Each audit event should include:

- Event ID
- Timestamp
- Device ID
- User account ID
- Actor ID
- Mode
- Proposed action
- Target app or data
- Sensitivity classification
- Permission mode
- Broker decision
- Identity confidence
- Result
- Error code when relevant

## Trust Dashboard

The trust dashboard is the primary user-facing explanation layer for Cove. It must expose:

- What Cove sees
- What Cove remembers
- What Cove controls
- What Cove is doing now
- Why Cove did it
- Which permission allowed it
- How to stop it
- Active agents
- Recent actions
- Permission mode
- Trusted devices
- Kill switch state
- Memory controls

## Trust Dashboard Detail Model

Each visible action, agent, or memory event should be explainable through the dashboard.

Required fields:

- What Cove sees: app, window, file, page, selected text, or permitted context source.
- What Cove remembers: memory namespace, category, last write, and reason.
- What Cove controls: app, integration, action class, and granted scope.
- What Cove is doing now: current task, current agent step, or idle state.
- Why Cove did it: user request, agent goal, schedule, or approved trigger.
- Which permission allowed it: Safe, Balanced, Autonomous, or explicit one-time approval.
- How to stop it: stop task, pause agent, revoke permission, disable memory, or activate kill switch.

The dashboard should use plain language for users and link to audit details only when deeper diagnostics are needed.

## Blocked By Default

Cove should never observe or control these by default:

- Password managers
- Banking apps
- Incognito tabs
- Private browsing windows
- Credential dialogs
- OS security prompts

Access to these surfaces requires explicit, temporary, high-confidence approval, and some actions should remain unsupported.

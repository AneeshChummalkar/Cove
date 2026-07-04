# Windows Overlay Runtime

Status: architecture specification only. No production code, APIs, or desktop automation are defined here.

## Purpose

Windows has no notch, so Cove should use a combination of system tray presence, floating orb, cursor popup, notification cards, and permission cards.

## Design

- System tray
- Floating orb
- Cursor popup
- Notification cards
- Permission cards

## Requirements

- Always accessible
- Minimal
- Interruptible
- Permission-aware
- Clear about current state
- Respectful of full-screen apps and focus mode
- Consistent with Windows notification patterns

## Surfaces

### System Tray

The system tray is the stable home for Cove.

Required actions:

- Open Cove
- View activity log
- View active agents
- Change permission mode
- Pause all agents
- Activate kill switch

### Floating Orb

The floating orb is the lightweight desktop presence.

States:

- Idle
- Listening
- Thinking
- Task running
- Agent running
- Permission required

Rules:

- It should be movable.
- It should collapse when inactive.
- It should never block important UI.
- It should expose pause or stop quickly.

### Cursor Popup

The cursor popup provides contextual suggestions and quick actions near the pointer.

Examples:

- Summarize PDF
- Summarize inbox
- Summarize video
- Draft reply

### Notification Cards

Notification cards communicate:

- Task completed
- Agent completed
- Agent paused
- Approval needed
- Security warning
- Kill switch activated

### Permission Cards

Permission cards must include:

- Exact action
- Target app or data
- Permission mode
- Why approval is needed
- Allow once
- Deny
- Pause agent when applicable

## Trust Rule

Windows overlays should make Cove available everywhere without feeling permanently in the way.

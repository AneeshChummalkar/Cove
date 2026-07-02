# Runtime

The Cove runtime is the local coordinator for all desktop AI behavior.

## Responsibilities

- Start on login when enabled
- Maintain device identity
- Coordinate voice, overlays, notifications, memory, and execution
- Route requests into task mode or agent mode
- Enforce permission decisions before actions run
- Persist local state
- Emit audit events
- Respect global pause and kill switch state

## Runtime Loop

1. Receive event from voice, overlay, schedule, hotkey, or agent trigger
2. Attach permitted desktop context
3. Classify intent
4. Select task mode or agent mode
5. Evaluate permissions
6. Execute or ask for confirmation
7. Observe result
8. Notify user
9. Record audit event

## Platform Boundary

Core runtime logic should stay cross-platform. Windows and macOS behavior should live in platform adapters for app launching, screen access, accessibility APIs, notifications, secure storage, and update handling.


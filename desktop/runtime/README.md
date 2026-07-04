# Runtime

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

The runtime is Cove's local orchestration layer. It owns process lifecycle, mode routing, service startup, event routing, configuration, device identity, and kill switch enforcement.

## Responsibilities

- Start and stop local services.
- Route input to Task Mode or Agent Mode.
- Enforce global pause and kill switch state.
- Coordinate permissions, memory, security, notifications, overlays, and OS adapters.
- Track current device and session state.
- Emit activity and audit events.

## Interfaces

Inputs:

- Voice commands
- Text commands
- Overlay events
- Notification actions
- Agent lifecycle events
- OS state changes

Outputs:

- Task execution requests
- Agent execution requests
- Permission evaluations
- Activity log events
- Security audit events
- Overlay state updates
- Notifications

## Phase 3 Notes

This folder should contain future runtime contracts, state diagrams, and lifecycle specs before any daemon or desktop shell code is added.

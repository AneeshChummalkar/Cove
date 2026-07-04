# Cove Phase 3 Desktop AI Runtime Blueprint

Status: architecture specification only. This document does not define production code or API integrations.

## Product Position

Cove is a desktop AI runtime inspired by Clicky, OpenAI Operator, Microsoft Copilot, and Cursor. Cove is not a chatbot. It is a local desktop presence that understands screen context, performs tasks, deploys agents, remembers user behavior with consent, operates applications, runs in the background, and prioritizes trust and security.

## Core Principles

- Desktop first: the runtime lives near the user's work instead of inside a website.
- Action first: Cove converts intent into controlled execution, not long chat threads.
- Trust first: the user can always see what Cove sees, remembers, and controls.
- Permissioned by design: all task and agent actions pass through a permission broker.
- Local first where possible: memory, identity state, audit logs, and sensitive settings should prefer local storage.
- Interruptible always: pause, deny, stop, and kill switch controls must be present across modes.

## Target Structure

```text
desktop/
  runtime/
  task-engine/
  agent-engine/
  memory/
  voice/
  permissions/
  security/
  overlays/
  os/
  notifications/
  integrations/
  ui/
docs/
research/
```

The active project places this structure under `cove/desktop`, with supporting specifications under `cove/docs` and research under `cove/research`.

## Runtime Domains

| Domain | Purpose |
| --- | --- |
| Runtime | Owns process lifecycle, event routing, mode selection, configuration, and kill switch enforcement. |
| Task Engine | Executes fast, bounded user commands such as opening apps, texting contacts, or summarizing a PDF. |
| Agent Engine | Creates persistent agents that plan, execute, remember, notify, pause, and resume. |
| Memory | Stores user-approved preferences, contacts, workflows, agents, history, voice profile, and trusted devices. |
| Voice | Captures voice input only when manually enabled and connected to a trusted microphone or Bluetooth headset. |
| Permissions | Classifies actions and applies Safe, Balanced, or Autonomous mode decisions. |
| Security | Provides face verification, voice verification, encryption, audit logs, and global kill switch controls. |
| Overlays | Displays listening state, action previews, cursor popups, assistant presence, and permission prompts. |
| OS | Encapsulates macOS and Windows adapters for accessibility, automation, notifications, and app control. |
| Notifications | Communicates background agent status, completed tasks, required approvals, and security events. |
| Integrations | Defines app connectors and tool boundaries for Gmail, browser, YouTube, Discord, VS Code, and more. |
| UI | Specifies macOS notch UI, Windows tray/orb, dashboard, activity log, and permission surfaces. |

## Mode Summary

Task mode handles immediate commands:

```text
User -> Intent -> Permission -> Execute -> Response
```

Agent mode handles autonomous, persistent goals:

```text
Goal -> Planner -> Agent Creation -> Memory -> Execution -> Notification
```

## Trust Model

Cove must always expose:

- What Cove sees
- What Cove remembers
- What Cove controls
- Which mode is active
- Which agent or task is acting
- Which permission rule allowed or blocked an action
- How to stop current and future work

The activity log is the canonical user-facing trust surface. The audit log is the canonical security record.

## Non-Goals For Phase 3

- No production runtime code.
- No API integration.
- No model provider integration.
- No real desktop automation.
- No biometric implementation.
- No background daemon implementation.

Phase 3 exists to make the architecture precise enough for later implementation.

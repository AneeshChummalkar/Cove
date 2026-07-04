# Mode System Specification

Status: architecture specification only.

## Overview

Cove has two primary execution modes: Task Mode and Agent Mode. Both modes share the same permission broker, memory policy, security layer, OS adapters, overlay system, and audit log.

## Task Mode

Task Mode is fast, direct, and bounded. It should be used when the user asks Cove to do one immediate thing.

Examples:

- "Cove open Spotify"
- "Cove text Sudharshan"
- "Cove open YouTube"
- "Cove summarize PDF"

Flow:

```text
User
  |
Intent
  |
Permission
  |
Execute
  |
Response
```

Task Mode requirements:

- Resolve intent quickly.
- Attach only the minimum context required.
- Ask before sensitive, irreversible, or externally visible actions.
- Produce a short completion response.
- Write an activity event and security audit event.
- Escalate to Agent Mode only when the request is persistent or open-ended.

Task Mode should not:

- Run indefinitely.
- Create recurring schedules without explicit user approval.
- Access excluded apps by default.
- Modify memory silently.

## Agent Mode

Agent Mode is autonomous, persistent, background-capable, and memory-enabled. It should be used when the user gives Cove an outcome that requires planning, repeated work, monitoring, or multi-step execution.

Examples:

- "Filter 500 unread emails and return top 10."
- "Monitor AI news."
- "Research robotics jobs."
- "Build a website."
- "Apply to internships."

Flow:

```text
Goal
  |
Planner
  |
Agent Creation
  |
Memory
  |
Execution
  |
Notification
```

Agent Mode requirements:

- Create a named agent with a clear goal, scope, tools, schedule, and permission level.
- Store agent state in a scoped memory namespace.
- Display active background work in Cove UI.
- Pause on uncertainty, denied permissions, repeated failure, or sensitive action boundaries.
- Notify the user when approval is needed or work completes.
- Allow pause, resume, terminate, and delete.

Agent Mode should not:

- Expand scope without approval.
- Grant itself new permissions.
- Hide execution or memory writes.
- Continue after the global kill switch is activated.

## Mode Selection Rules

| Input Shape | Preferred Mode |
| --- | --- |
| Single app launch | Task |
| Single message or reply | Task |
| One document summary | Task |
| Multi-step research | Agent |
| Monitoring or scheduled work | Agent |
| Bulk email processing | Agent |
| Website or app building | Agent |
| Applying to internships or jobs | Agent |

## Shared Safety Gates

Both modes must pass proposed actions through these gates:

1. Identity and device trust check.
2. App and data sensitivity classification.
3. Permission mode evaluation.
4. User confirmation when required.
5. Execution observation.
6. Activity and audit logging.

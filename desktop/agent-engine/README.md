# Agent Engine

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

The agent engine creates and supervises persistent agents that can plan, execute, remember, pause, resume, notify, and complete background work.

## Flow

```text
Goal -> Planner -> Agent Creation -> Memory -> Execution -> Notification
```

## Responsibilities

- Convert a user goal into a scoped agent definition.
- Create agent memory namespaces.
- Maintain agent lifecycle state.
- Run background execution loops.
- Ask for approval at sensitive boundaries.
- Notify the user when intervention or completion occurs.
- Support pause, resume, terminate, and delete.

## Agent Definition

Each agent must declare:

- Goal
- Scope
- Trigger or schedule
- Permission mode
- Tool access
- Memory namespace
- Status
- Last action
- Next planned action
- Audit history

## Safety Rules

Agents cannot grant themselves new permissions, hide activity, expand scope silently, or continue after kill switch activation.

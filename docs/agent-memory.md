# Agent Memory

Status: architecture specification only. No production code, APIs, or desktop automation are defined here.

## Purpose

Every Cove agent must have an isolated memory namespace. Agent memory lets persistent agents remember relevant state without mixing unrelated goals, users, apps, or permissions.

## Required Agent Fields

Every agent must have:

- Agent ID
- Goal
- Scope
- Permission Mode
- Memory Namespace

## Example

```text
Agent:
AI News Monitor

Agent ID:
agent_ai_news_monitor_001

Goal:
Monitor AI news and notify the user about important updates.

Scope:
Approved AI news sources and user-selected notification schedule.

Permission Mode:
Balanced

Memory Namespace:
agents/agent_ai_news_monitor_001
```

Memory:

- sources
- summaries
- history
- notifications
- preferences

## Namespace Model

Each agent namespace should contain only memory needed for that agent's goal.

Suggested namespace sections:

- `profile`: agent name, goal, scope, and permission mode
- `sources`: approved sources, apps, files, or accounts
- `state`: current progress and resumable execution state
- `history`: completed steps and prior results
- `preferences`: user preferences specific to the agent
- `notifications`: notification history and pending approvals
- `artifacts`: generated summaries, drafts, reports, and references
- `audit_refs`: references to audit events

## Requirements

Agent memory must be:

- Isolated
- Exportable
- Deletable
- Auditable
- Scoped to the agent goal
- Controlled by the user
- Paused when the agent is paused
- Deleted or archived when the agent is deleted, according to user choice

## Isolation Rules

- Agents cannot read another agent's namespace by default.
- Agents cannot write to global user memory without permission.
- Agents cannot expand memory scope without approval.
- Agent memory must preserve the permission mode that allowed each write.
- Sensitive memory must be stored separately from ordinary progress state.

## Export Rules

Export should include:

- Agent profile
- Goal and scope
- Permission mode history
- Memory entries
- Generated artifacts
- Activity history
- Audit references

Export should not include:

- Credentials
- Raw secrets
- Unapproved sensitive content
- Other agents' memory

## Deletion Rules

Deleting an agent should offer:

- Delete agent only
- Delete agent and memory
- Export before deletion
- Archive read-only history

Deletion must create an activity event and an audit event.

## Audit Rules

Every agent memory write should record:

- Agent ID
- Namespace
- Memory section
- Write reason
- Permission mode
- User approval when required
- Timestamp
- Source action or observation

## Trust Rule

The user must be able to inspect what an agent remembers and why it remembers it.

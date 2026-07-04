# Task Engine

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

The task engine executes immediate, bounded commands such as opening apps, texting contacts, opening YouTube, or summarizing a PDF.

## Flow

```text
User -> Intent -> Permission -> Execute -> Response
```

## Responsibilities

- Parse a bounded task request from runtime intent.
- Resolve app, contact, file, or surface targets.
- Request permission before execution.
- Run one short action or a tightly bounded chain of actions.
- Return completion, failure, or clarification state.
- Write activity and audit events through the runtime.

## Constraints

- No persistent background loops.
- No silent memory writes.
- No access to blocked surfaces by default.
- Escalate to Agent Mode for monitoring, scheduling, repeated work, or broad goals.

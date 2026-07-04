# Complexity Router

Status: architecture specification only. No production code, APIs, or desktop automation are defined here.

## Purpose

Cove should automatically determine whether a user request belongs in Task Mode or Agent Mode. The router exists before execution and decides how much planning, permission review, memory, and visibility the request needs.

## Architecture

```text
User Request
      |
Complexity Analyzer
      |
Task Mode OR Agent Mode
      |
Execution
```

## Mode Targets

Task Mode is for immediate, bounded commands.

Examples:

- Open Spotify
- Open YouTube
- Text Sudharshan
- Summarize PDF

Agent Mode is for multi-step, persistent, bulk, recurring, or open-ended work.

Examples:

- Filter 500 unread emails and return top 10
- Monitor AI news
- Research robotics jobs
- Apply to internships
- Build a website

## Complexity Signals

The analyzer should detect:

- Multi-step requests
- Long-running requests
- Monitoring requests
- Bulk processing requests
- Recurring requests
- Requests that require planning
- Requests that need persistent memory
- Requests that can continue after the immediate user interaction ends
- Requests that affect external systems, accounts, or people

## Routing Heuristics

Route to Task Mode when:

- The action has one clear target.
- The action can finish immediately.
- The action has no background loop.
- The action does not require ongoing memory.
- The action can be confirmed with a short response.

Route to Agent Mode when:

- The goal requires multiple dependent steps.
- The request contains a quantity or batch, such as 500 emails.
- The request contains watch, monitor, track, apply, research, build, organize, manage, or repeat.
- The work may take minutes, hours, or days.
- The work needs a schedule, trigger, or background status.
- The work needs an agent memory namespace.

## Confidence Scoring

The complexity router should return a score from 0.00 to 1.00 for each mode.

Example:

```text
Request: "Open Spotify"
Task Mode confidence: 0.98
Agent Mode confidence: 0.02
Decision: Task Mode
```

Example:

```text
Request: "Monitor AI news and notify me every morning"
Task Mode confidence: 0.05
Agent Mode confidence: 0.95
Decision: Agent Mode
```

## Confidence Bands

| Band | Behavior |
| --- | --- |
| 0.90 to 1.00 | Route automatically. |
| 0.70 to 0.89 | Route automatically but show mode in the preview. |
| 0.50 to 0.69 | Ask a short clarification. |
| Below 0.50 | Do not execute; ask the user to clarify the goal. |

## Clarification Examples

If the request is ambiguous, Cove should ask a mode-oriented question.

Example:

```text
Do you want me to summarize this PDF once, or create an agent to monitor similar documents?
```

Example:

```text
Should I send one message now, or keep following up until they reply?
```

## Required Output

The complexity analyzer returns:

- Original request
- Chosen mode
- Task Mode confidence
- Agent Mode confidence
- Detected complexity signals
- Reason for routing
- Whether clarification is required
- Permission preview level

## Safety Rule

The complexity router does not execute anything. It only classifies the request and sends the result to the runtime mode router.

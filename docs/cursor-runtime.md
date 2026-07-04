# Cursor Runtime

Status: architecture specification only. No production code, APIs, or desktop automation are defined here.

## Purpose

The cursor runtime is Cove's contextual desktop presence near the user's pointer. Inspired by Clicky-style interaction, it provides mouse-aware suggestions, hover assistance, quick actions, and permission-aware previews.

## Requirements

- Mouse tracking
- Contextual popup
- Contextual suggestions
- Hover assistance
- Quick actions
- Visible runtime state
- Immediate pause or dismiss controls
- Permission prompts for sensitive actions

## Context Examples

Hover PDF:

```text
Need a summary?
```

Hover Gmail:

```text
Summarize inbox?
```

Hover YouTube:

```text
Summarize video?
```

## States

| State | Meaning |
| --- | --- |
| idle | Cove is available but not acting. |
| listening | Cove is capturing command input. |
| thinking | Cove is classifying intent or planning. |
| task running | Cove is executing a bounded task. |
| agent running | Cove has a persistent agent active. |
| permission required | Cove needs user approval before continuing. |

## Behavior By State

Idle:

- Show no popup unless the user hovers an eligible context or invokes Cove.
- Avoid visual noise.

Listening:

- Show a clear capture indicator.
- Support cancel and correction.

Thinking:

- Show lightweight progress.
- Avoid implying execution has started.

Task running:

- Show the target and action.
- Offer stop when possible.

Agent running:

- Show agent name and current step.
- Offer pause and activity log access.

Permission required:

- Show exact action, target, and permission mode.
- Provide allow once, deny, and pause controls.

## Suggestion Rules

Suggestions should appear only when:

- The surface is allowed by screen understanding policy.
- The context is clear enough to avoid confusion.
- The suggested action is low-risk or requires preview before execution.
- The popup will not obscure important content.

Suggestions should not appear over:

- Password managers
- Banking apps
- Incognito tabs
- Credential dialogs
- OS security prompts

## Quick Actions

Candidate quick actions:

- Summarize
- Explain
- Draft reply
- Save note
- Open with Cove
- Create agent
- Pause agent
- View activity

## Trust Rule

The cursor runtime should make Cove feel present without making the desktop feel watched. It should explain why a suggestion appears when the user asks for details.

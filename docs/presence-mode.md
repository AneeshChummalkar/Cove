# Presence Mode

Status: architecture specification only. No production code, APIs, or desktop automation are defined here.

## Purpose

Presence Mode defines how visible, proactive, and autonomous Cove feels on the desktop. It controls how often Cove appears, observes context, suggests actions, runs agents, and notifies the user.

Presence Mode is separate from Permission Mode. Permission Mode decides what Cove is allowed to do. Presence Mode decides how strongly Cove shows up.

## Modes

- GHOST
- ASSISTANT
- COMPANION
- AGENTIC

## Mode Matrix

| Mode | Popup Frequency | Screen Observation | Suggestion Frequency | Agent Activity | Notification Policy | Trust Implications |
| --- | --- | --- | --- | --- | --- | --- |
| GHOST | Almost never; only on explicit invocation. | Off by default except explicit user-selected context. | None unless requested. | No proactive agents; only manually started work. | Critical security and explicit task completion only. | Highest quiet mode; user has maximum control and Cove feels least present. |
| ASSISTANT | Low; appears for commands, confirmations, and important status. | Limited to active task context with permission. | Low; only high-confidence, low-risk suggestions. | Agents may run only when explicitly created and visible. | Task results, approval requests, failures, and security events. | Recommended default for trust-building; Cove is helpful but restrained. |
| COMPANION | Medium; contextual popup can appear during eligible work. | Allowed surfaces may be observed while Cove is active. | Medium; suggestions appear for clear opportunities like PDFs, Gmail, or YouTube. | Agents can run in background within approved scopes. | Background summaries, agent milestones, approvals, and security events. | More useful but more present; dashboard must make observation and memory clear. |
| AGENTIC | High; Cove can maintain visible background presence. | Broadest approved observation inside user-defined scopes. | High within approved apps and workflows. | Persistent agents can monitor, plan, and execute according to permission mode. | Frequent agent progress, approvals, exceptions, and completion notifications. | Highest capability and highest trust burden; requires excellent activity logs, stop controls, and scope visibility. |

## GHOST

GHOST mode makes Cove nearly invisible.

Behavior:

- Cove appears only when invoked by the user.
- No ambient suggestions.
- No passive screen observation.
- No proactive agent creation.
- Notifications are limited to security-critical events and explicit task completions.

Best for:

- Sensitive work
- New users
- Presentations
- Shared screens
- Low-distraction environments

Trust implication:

GHOST maximizes user control and minimizes surprise, but Cove may feel less useful because it waits for explicit commands.

## ASSISTANT

ASSISTANT mode is the recommended default.

Behavior:

- Cove appears for commands, confirmations, and important status.
- Screen observation is limited to the active task and approved context.
- Suggestions are rare and high-confidence.
- Agents run only after explicit creation.
- Notifications focus on results, failures, approvals, and security events.

Best for:

- Daily desktop use
- Building trust
- Task Mode-heavy workflows
- Users who want help without ambient presence

Trust implication:

ASSISTANT balances usefulness and restraint. The user should rarely wonder why Cove appeared.

## COMPANION

COMPANION mode makes Cove more context-aware and proactive.

Behavior:

- Cursor popups and contextual suggestions may appear on approved surfaces.
- Cove may observe allowed screen context while active.
- Suggestions can appear for clear opportunities, such as summarizing a PDF, inbox, or video.
- Background agents can run within approved scopes.
- Notifications include agent milestones and useful summaries.

Best for:

- Research workflows
- Email workflows
- Document-heavy work
- Users who want Cove to notice useful opportunities

Trust implication:

COMPANION increases value by increasing presence. Cove must clearly show what it sees and why a suggestion appeared.

## AGENTIC

AGENTIC mode makes Cove a persistent operating layer.

Behavior:

- Cove can maintain a visible desktop presence.
- Agents can monitor, plan, and execute in the background.
- Suggestions can be frequent inside approved workflows.
- Notifications include progress, approvals, exceptions, and completions.
- The activity log and kill switch must be prominent.

Best for:

- Persistent agents
- Monitoring workflows
- Bulk processing
- Long-running goals
- Users who have already configured trust boundaries

Trust implication:

AGENTIC has the highest capability and the highest trust burden. Cove must expose scope, current activity, memory writes, permission decisions, and stop controls at all times.

## Interaction With Permission Mode

Presence Mode does not grant capability by itself.

Examples:

- AGENTIC plus Safe means Cove may be highly visible but still asks before most actions.
- GHOST plus Autonomous means approved agents may have broad permission, but Cove avoids proactive popups.
- COMPANION plus Balanced means Cove can suggest and run approved background work while asking for important actions.

## Required Controls

Users must be able to:

- Change Presence Mode quickly.
- Temporarily quiet Cove.
- Pause suggestions.
- Pause all agents.
- Disable screen observation.
- Open the activity log.
- Activate the kill switch.

## Trust Rule

The more present Cove becomes, the more explicit its explanations must be. AGENTIC mode requires the strongest visibility into what Cove sees, remembers, controls, and is doing now.

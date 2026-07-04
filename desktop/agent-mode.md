# Agent Mode

Agent mode creates persistent agents that run over time.

## Examples

- "Filter 500 unread emails and return top 10."
- "Monitor AI news."
- "Research robotics jobs."
- "Build a website."
- "Apply to internships."
- "Track AI news"
- "Manage Gmail"
- "Review resumes"
- "Plan trip"

## Agent Definition

An agent includes:

- Goal
- Scope
- Trigger or schedule
- Permission mode
- Tool access
- Memory namespace
- Current status
- Audit log
- Pause and kill controls

## Lifecycle

1. Create agent
2. Define scope
3. Request initial permissions
4. Run background loop
5. Ask for approval when needed
6. Report progress
7. Pause, complete, or terminate

## Safety

Persistent agents must always be visible in runtime status, interruptible by the user, and constrained by scoped permissions.

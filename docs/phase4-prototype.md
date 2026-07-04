# Phase 4 Prototype

Status: prototype planning document. This explicitly excludes AI, APIs, and desktop automation.

## Goal

Build a fake Cove desktop experience that allows a user to feel the product model before any real integrations exist.

The prototype should answer:

- What does Cove feel like on the desktop?
- How do Task Mode and Agent Mode differ?
- How do permission prompts build trust?
- Can users understand what Cove sees, remembers, controls, and is doing now?

## Hard Constraints

No AI.

No APIs.

No desktop automation.

No real screen reading.

No real app control.

No biometric verification.

No production runtime code.

## Build

The first prototype should include:

- Fake Cove desktop app
- Fake notch
- Fake cursor popup
- Fake Task Mode
- Fake Agent Mode
- Fake permission prompts
- Fake activity log

## Prototype Surfaces

### Fake Cove Desktop App

Shows:

- Current permission mode
- Active task or agent
- Activity log
- Memory preview
- Trusted device mock state
- Kill switch state

### Fake Notch

macOS-style status surface with states:

- Cove listening...
- Cove processing...
- Agent running...
- Permission required.

### Fake Cursor Popup

Contextual prompts:

- Hover PDF: "Need a summary?"
- Hover Gmail: "Summarize inbox?"
- Hover YouTube: "Summarize video?"

### Fake Task Mode

Scripted tasks:

- Open Spotify
- Open YouTube
- Text Sudharshan
- Summarize PDF

Expected behavior:

- Route to Task Mode.
- Show permission prompt when needed.
- Show completion state.
- Add fake activity event.

### Fake Agent Mode

Scripted agents:

- Filter 500 unread emails and return top 10
- Monitor AI news
- Research robotics jobs
- Apply to internships
- Build a website

Expected behavior:

- Route to Agent Mode.
- Create fake agent identity.
- Show scoped memory namespace.
- Show progress states.
- Pause for fake permission approval.
- Add fake activity events.

### Fake Permission Prompts

Prompts should include:

- Action
- Target
- Mode
- Reason
- Allow once
- Deny
- Pause agent when applicable

### Fake Activity Log

Events should show:

- What Cove saw
- What Cove did
- Why Cove did it
- Which permission allowed it
- What memory changed
- How to stop or undo when relevant

## Success Criteria

The prototype succeeds when a user can:

- Distinguish Task Mode from Agent Mode.
- Understand why Cove asked for permission.
- See what Cove is doing now.
- Inspect fake memory and fake activity.
- Stop or pause fake work.
- Experience the desktop presence without any real integrations.

## Phase 4 Exit Criteria

- No real external services are used.
- No user data is read.
- No app is controlled.
- All flows are scripted.
- All actions are visibly logged.
- The prototype makes the Phase 3 architecture tangible.

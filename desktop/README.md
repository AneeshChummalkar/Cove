# Cove Desktop Architecture

The desktop runtime is the primary Cove product. It runs locally on Windows and macOS and coordinates voice input, screen context, permissions, memory, task execution, agent execution, notifications, overlays, and security.

## Runtime Components

- Runtime core
- Voice system
- Overlay system
- Notification system
- Permission broker
- Memory service
- Task mode executor
- Agent mode host
- Security service
- Face recognition module
- Voice recognition module
- Platform adapters for Windows and macOS

## Runtime Core

The runtime core owns process lifecycle, local configuration, account state, device identity, model routing, event routing, and execution orchestration.

Responsibilities:

- Start and stop background services
- Register OS-level launch behavior
- Coordinate permissions across tools
- Route commands to task mode or agent mode
- Maintain local execution state
- Emit audit events
- Enforce kill switch state

## Platform Adapters

Windows and macOS support should be built through platform adapters rather than duplicated runtime logic.

Adapter responsibilities:

- Application launching
- Window focus and enumeration
- Notification integration
- Accessibility API access
- Screen capture permission checks
- Microphone permission checks
- Secure credential storage
- Local file access mediation

## Overlays

Overlays are lightweight desktop UI surfaces used for command capture, confirmations, status, and agent presence.

Overlay surfaces:

- Wake overlay
- Command confirmation overlay
- Permission prompt
- Agent status strip
- Action preview
- Error and recovery panel

Overlay principles:

- Stay out of the user's way
- Never hide destructive actions
- Show what Cove is doing right now
- Make stop, pause, and deny actions obvious
- Keep persistent agents visible without becoming a dashboard

## Voice System

The voice system converts speech into intent and manages conversational state for short interactions.

Pipeline:

1. Wake detection
2. Audio capture
3. Voice identification check when enabled
4. Speech-to-text
5. Intent parsing
6. Context attachment
7. Permission evaluation
8. Execution dispatch
9. Spoken or visual response

Design requirements:

- Low-latency capture
- Local-first wake handling
- Clear recording indicator
- Push-to-talk fallback
- Microphone permission isolation
- Support for corrections and cancellation

## Notifications

Notifications communicate background events, required confirmations, completed tasks, and security alerts.

Notification types:

- Task complete
- Agent needs approval
- Agent paused
- Permission denied
- New device login
- Security warning
- Kill switch activated

## Permissions

Cove supports three permission levels:

- Ask every action
- Ask important actions only
- Fully autonomous

The permission broker evaluates every proposed action before execution.

Evaluation inputs:

- User permission mode
- Agent or task scope
- App sensitivity
- Data sensitivity
- Action reversibility
- Identity confidence
- Device trust state
- Recent audit history

Important actions should include sending messages, deleting files, making purchases, changing security settings, sharing private data, installing software, and granting new access.

## Memory

Memory should be local-first and user-controlled.

Memory categories:

- User preferences
- Contacts and aliases
- Workflow history
- App-specific instructions
- Agent goals
- Trusted permissions
- Rejected actions
- Security events

Memory controls:

- Inspect
- Edit
- Delete
- Export
- Disable
- Sync selectively

## Task Mode

Task mode handles immediate commands that start and end quickly.

Examples:

- Open YouTube
- Text Rahul
- Reply to email

Execution flow:

1. Capture command
2. Resolve target app or service
3. Check permission level
4. Preview important actions
5. Execute
6. Confirm completion
7. Write audit event

## Agent Mode

Agent mode creates persistent agents.

Examples:

- Track AI news
- Manage Gmail
- Review resumes
- Plan trip

Agent properties:

- Goal
- Scope
- Schedule or trigger
- Tool access
- Permission level
- Memory namespace
- Status
- Audit log
- Pause and kill controls

Agent lifecycle:

1. Create
2. Configure scope
3. Request permissions
4. Run background loop
5. Ask for approval when needed
6. Report progress
7. Pause, complete, or terminate

## Security

Security is enforced across runtime, identity, permissions, storage, sync, and audit.

Required primitives:

- Device identity
- Secure local storage
- Signed updates
- Permission audit log
- Kill switch
- Sensitive action classification
- Session lock awareness

Future support:

- Voice identification
- Face identification
- Device verification
- Cross-device trust management
- Tamper-resistant audit logs

## Face Recognition

Face recognition is a future optional security layer.

Potential uses:

- Confirm user presence
- Increase confidence for important actions
- Lock Cove when the user leaves
- Detect unknown users during sensitive requests

Requirements:

- Explicit opt-in
- Local-first processing
- Clear camera indicator
- No silent enrollment
- Easy disable and delete controls

## Voice Recognition

Voice recognition is a future optional identity layer.

Potential uses:

- Verify who issued a command
- Gate high-risk actions
- Detect unknown speakers
- Support household or team profiles

Requirements:

- Explicit enrollment
- Local-first matching where practical
- Confidence thresholds
- Recovery path for false rejection
- No irreversible action based only on voice confidence


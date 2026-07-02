# Clicky Architecture Analysis

This document analyzes Clicky as a reference point for future Cove implementation decisions.

Do not clone Clicky. Do not rename Clicky. Cove should learn from the architectural category while developing its own product model, permission system, identity layer, and desktop runtime.

## Architecture

Clicky appears to belong to a class of desktop AI runtimes that combine local presence, voice interaction, screen context, overlays, and agentic execution.

Likely architectural layers:

- Desktop shell process
- Voice capture and transcription pipeline
- Screen understanding pipeline
- Overlay UI layer
- Agent execution layer
- Tool and app control layer
- Cursor or presence layer
- Cloud model routing
- Account and sync services

## Voice Pipeline

A Clicky-style voice pipeline likely includes:

1. Wake or push-to-talk activation
2. Microphone capture
3. Speech-to-text
4. Intent extraction
5. Desktop context attachment
6. Action planning
7. Confirmation or execution
8. Spoken or overlay response

Important lessons for Cove:

- Voice latency determines whether the product feels native
- Recording state must be visible
- Users need quick correction and cancellation
- Identity and permissions should be built into the pipeline, not added later

## Screen Understanding

Clicky-like systems use screen context to understand what the user is looking at and what action may be relevant.

Possible inputs:

- Active window title
- Application identity
- Accessibility tree
- OCR
- Screenshot-derived visual context
- Browser URL or tab metadata when permitted
- Selected text
- Cursor location

Important lessons for Cove:

- Screen access must be permissioned and explainable
- Accessibility APIs are often more reliable than raw screenshots
- Sensitive apps require higher permission thresholds
- Screen understanding should degrade gracefully when access is denied

## Overlay System

The overlay system provides local presence without forcing users into a web dashboard.

Likely overlay roles:

- Listening indicator
- Command capture
- Permission confirmation
- Action preview
- Agent activity indicator
- Error recovery
- Cursor-adjacent hints

Important lessons for Cove:

- Overlays should be fast, native-feeling, and dismissible
- The user should always know when an agent is acting
- Confirmation prompts should name the exact action and target
- Overlay UI should support keyboard, mouse, and voice

## Agent Execution

Clicky-like agent execution bridges user goals with desktop tools and services.

Likely execution model:

- Interpret goal
- Build plan
- Inspect desktop or app state
- Select tool or app action
- Request permission when needed
- Execute step
- Observe result
- Continue, pause, or ask for help

Important lessons for Cove:

- Agents need scoped permissions
- Persistent agents need clear lifecycle states
- Users need audit logs and pause controls
- Agents should be resumable after restart
- Tool failures should be visible and recoverable

## Desktop Runtime

A desktop runtime is responsible for more than UI. It must manage local services, OS integrations, permissions, identity, memory, and background work.

Expected capabilities:

- Start on login
- Run background workers
- Launch and control applications
- Handle OS permissions
- Store local secrets securely
- Manage updates
- Show notifications
- Persist agent state
- Sync selectively with cloud services

## Cursor Presence

Clicky-style systems may use cursor presence to make AI action visible and grounded.

Potential forms:

- Cursor-following overlay
- Highlighted target regions
- Action preview near the cursor
- Visual indication of automated movement
- Presence marker when an agent is operating

Important lessons for Cove:

- Cursor presence should build trust, not distract
- Automated control should be obvious
- Users need immediate stop controls
- Cursor-adjacent UI must not block the user's work

## Strengths

- Native desktop presence
- Voice-first interaction
- Ability to use current screen context
- Reduced need to switch into a web app
- Potential for fast task execution
- Natural bridge between user intent and local apps

## Weaknesses

- Permission boundaries can become unclear
- Screen capture can feel invasive
- Voice recognition errors can cause risky actions
- Agent activity may be hard to audit
- Native desktop integrations are complex across platforms
- Users may not trust background execution without strong controls

## Areas Cove Can Improve

Cove can improve by making security, permissions, and memory first-class from the beginning.

Improvement areas:

- Clear three-level permission model
- Local-first memory with user inspection and deletion
- Strong audit logs for every action
- Kill switch across all agents
- Optional voice and face identification
- Device verification and revocation
- Separate task mode and agent mode
- Website limited to support flows
- Explicit Windows and macOS platform architecture

## Implementation Takeaways

- Build the runtime around permissions, not around chat
- Use overlays for confirmations and status, not dashboard replacement
- Treat persistent agents as local background processes with visible state
- Prefer platform adapters for OS-specific behavior
- Make every sensitive action auditable
- Keep the website quiet and operational


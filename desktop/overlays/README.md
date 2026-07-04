# Overlays

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

Overlays make Cove visible at the moment of action. They support command capture, permission prompts, action previews, agent status, cursor-adjacent context, and emergency stop controls.

## Surfaces

- Wake indicator
- Voice capture panel
- Command preview
- Permission prompt
- Cursor popup
- Agent status strip
- Floating assistant
- Error recovery panel
- Kill switch control

## Design Rules

- Keep surfaces small, fast, and dismissible.
- Show recording state clearly.
- Show exact action and target before sensitive execution.
- Keep pause, deny, and stop controls obvious.
- Avoid covering the user's current work.

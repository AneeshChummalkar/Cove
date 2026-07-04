# Memory

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

Memory stores user-approved context that helps Cove behave consistently over time while staying inspectable and controllable.

## Memory Categories

- Preferences
- Contacts
- Writing style
- Voice profile
- Workflows
- Agents
- History
- Trusted devices

## Controls

Users must be able to:

- Inspect memory
- Edit memory
- Delete memory
- Export memory
- Disable memory
- Selectively sync memory

## Storage Boundaries

Separate:

- Plain settings
- Sensitive settings
- User memory
- Agent state
- Activity log
- Security audit log
- Credentials and tokens

Sensitive values should use OS secure storage and local encryption where appropriate.

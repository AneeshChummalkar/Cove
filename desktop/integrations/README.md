# Integrations

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

Integrations define controlled access to apps, services, and local tools. They should expose typed capabilities to the runtime instead of letting agents operate arbitrary surfaces.

## Candidate Surfaces

- Desktop
- Browser
- Gmail
- YouTube
- WhatsApp
- Discord
- VS Code
- Local files
- Other user-approved applications

## Blocked By Default

- Password managers
- Banking apps
- Incognito tabs
- Private browsing windows
- Credential dialogs
- OS security prompts

## Integration Rules

- Declare readable context.
- Declare controllable actions.
- Declare sensitivity classes.
- Respect app-specific permission scopes.
- Emit activity and audit events for every action.

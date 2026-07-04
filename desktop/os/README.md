# OS Adapters

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

OS adapters isolate platform-specific behavior from the runtime core.

## macOS Responsibilities

- App launching and focus
- Window enumeration
- Accessibility API access
- Screen Recording permission checks
- Microphone permission checks
- Notification Center integration
- Keychain storage
- Login item registration
- Menu bar or notch UI support

## Windows Responsibilities

- App launching and focus
- Window enumeration
- UI Automation access
- Graphics capture permission checks
- Microphone permission checks
- Toast notifications
- Credential Manager storage
- Startup task registration
- System tray and floating orb support

## Rule

Runtime logic should depend on adapter contracts, not direct OS calls.

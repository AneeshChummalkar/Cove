# Tech Stack Evaluation

Status: research-backed architecture recommendation. This document does not select final production dependencies.

## Evaluation Criteria

- Native desktop feel on macOS and Windows
- Access to OS automation and accessibility APIs
- Secure local storage support
- Overlay quality
- Background runtime support
- Update and signing strategy
- Model provider flexibility
- Local model option
- Developer velocity
- Long-term maintainability

## Desktop Shell

### Electron

Strengths:

- Mature cross-platform desktop app framework.
- Strong ecosystem for tray apps, windows, overlays, auto updates, and native modules.
- Works naturally with existing web UI skills.
- Easier hiring and iteration.

Risks:

- Larger app footprint.
- Native automation and accessibility still require platform-specific modules.
- Security hardening must be deliberate.

Best fit:

- Fast Phase 4 prototyping and UI-heavy desktop surfaces.

### Tauri

Strengths:

- Smaller binary footprint.
- Rust backend is attractive for secure local runtime work.
- Good separation between UI and privileged native operations.

Risks:

- More native engineering complexity.
- Smaller ecosystem than Electron for advanced overlays and automation.
- Requires stronger Rust expertise.

Best fit:

- Security-sensitive runtime once architecture stabilizes.

### Recommendation

Use Electron for the first prototype if speed is the priority. Keep the runtime boundary clean enough that a Tauri or native shell can replace it later. For a trust-heavy desktop runtime, avoid coupling all privileged behavior directly to renderer UI code.

## Model Layer

### OpenAI

Strengths:

- Strong general planning, tool use, multimodal, and realtime voice ecosystem.
- Good fit for task interpretation, summarization, and agent reasoning.

Risks:

- Cloud dependency for sensitive contexts.
- Requires strict data minimization and consent controls.

### Claude

Strengths:

- Strong long-context reasoning and writing.
- Useful for research agents and document-heavy workflows.

Risks:

- Same cloud sensitivity concerns.
- Provider-specific behavior must be abstracted.

### Local Models

Strengths:

- Privacy-preserving for classification, routing, simple extraction, and local summarization.
- Good fit for wake handling, sensitive action classification, and offline fallback.

Risks:

- Lower capability depending on device.
- More complexity around model packaging, performance, and updates.

### Recommendation

Create a model router abstraction in the architecture. Support cloud models for high-capability reasoning, local models for privacy-sensitive classification and fallback, and user-visible routing controls for sensitive contexts.

## Screen Understanding

Inputs to evaluate:

- Accessibility tree
- Active window metadata
- Browser extension metadata
- OCR
- Screenshots
- Selected text
- Cursor position

Recommendation:

Prefer accessibility APIs and structured app integrations before screenshots. Use screenshot or OCR as a fallback when the user has granted screen access and the app is not restricted.

## Desktop Automation

Approaches:

- OS accessibility APIs
- App-specific APIs
- Browser extension bridge
- Keyboard and mouse automation
- File system operations
- URL schemes and command-line launchers

Recommendation:

Prefer app-specific and accessibility actions over raw mouse automation. Raw UI automation is useful but should be visible, interruptible, and audited.

## Platform APIs

macOS:

- Accessibility API
- Screen Recording permission
- Microphone permission
- Keychain
- Notification Center
- Login items
- Notch or menu bar surfaces

Windows:

- UI Automation
- Graphics capture
- Microphone permission
- Credential Manager
- Toast notifications
- System tray
- Startup tasks

## Voice

Voice mode must be disabled by default. It becomes available only after manual enablement and trusted input verification.

Supported input policy:

- Bluetooth headset
- Trusted microphone

Voice output policy:

- Male voices
- Female voices
- Future voice cloning with explicit consent and separate controls

## Architecture Recommendation

Phase 4 should prototype:

- Electron shell for UI and background orchestration.
- Native adapter boundary for macOS and Windows.
- Model router interface without provider lock-in.
- Local-first memory storage design.
- Permission broker before real tool integrations.
- Simulated app adapters before live automation.

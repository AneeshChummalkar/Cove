# Cove Roadmap

## Vision

Cove is a desktop-first personal AI runtime that lives on the user's computer: voice-first, privacy-first, permission-aware, memory-capable, and deeply integrated with macOS and Windows without becoming a web dashboard.

## Current Sprint

- Validate the native Settings foundation on macOS hardware.
- Preserve the notch overlay while Settings evolves into Cove's control surface.
- Keep authentication, permission, memory, and runtime service controls explicit placeholders until their native services are implemented.

## Completed

- ✅ Completed: Phase 3 architecture and specifications drafted in `docs/`.
- ✅ Completed: Phase 4 simulated runtime direction documented.
- ✅ Completed: Electron notch overlay prototype created.
- ✅ Completed: Native Swift AppKit notch overlay prototype created.
- ✅ Completed: Native notch overlay safe-area detection, hover expansion, settings popover, mouse passthrough, blur, and vibrancy compiled and ran.
- ✅ Completed: Native notch overlay production-polish pass for notch attachment, translucent glass, spring animation, visual spacing, inactive opacity, and settings popover appearance.
- ✅ Completed: Native AppKit Settings foundation with a dedicated glass window, animated custom sidebar, modular section controllers, reusable cards and controls, persisted theme switching, and future-facing Account, Privacy, Permissions, AI, General, and About surfaces.

## Next Sprint

- Connect the native macOS notch overlay as a presence surface for simulated runtime states.
- Validate the native macOS notch overlay on real macOS hardware, including notched and non-notched displays.
- Compile and visually validate the native Settings window on macOS in System, Light, and Dark appearances.
- Connect real permission status detection after the Settings foundation is validated; keep permission actions non-functional until then.
- Begin Phase 5 local runtime lifecycle work after Phase 4 exit criteria are met.

## Future

- Phase 5: Local runtime lifecycle, secure local settings, permission detection, kill switch, and append-only audit logging.
- Phase 6: Controlled low-risk integrations for app launch, focus, read-only context, and browser/document experiments.
- Phase 7: Persistent background agents with scoped memory, approval queues, notifications, and resumability.
- Phase 8: Manually enabled voice mode with optional identity verification.
- Phase 9: Production hardening for signing, updates, storage, telemetry policy, crash recovery, accessibility, performance, and battery usage.

## Technical Debt

- Add macOS-based build verification for `native-notch-overlay`; the current container does not include `swift`, `xcodebuild`, or AppKit.
- Resolve root-vs-nested repository duplication so `native-notch-overlay/` and `cove/native-notch-overlay/` cannot drift accidentally.
- Capture hardware-specific notch geometry screenshots to avoid tuning solely from safe-area estimates.

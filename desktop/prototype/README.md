# Cove Phase 4 Experience Prototype

Status: prototype only. This app uses fake JSON data and local React state. It does not connect to AI providers, APIs, screen readers, OCR, browser automation, biometrics, or desktop control.

## Run

```bash
cd cove/desktop/prototype
npm install
npm run dev
```

The `dev` script starts Vite and then launches the Electron shell against the local Vite URL.

For a browser-only preview while iterating:

```bash
npm run preview
```

## Included Surfaces

- Task Mode and Agent Mode simulations
- Presence modes: Ghost, Assistant, Companion, Agentic
- Permission modes: Safe, Balanced, Autonomous
- Fake macOS notch
- Fake Windows floating orb
- Fake cursor runtime popups
- Fake permission dialogs
- Fake activity log
- Trust dashboard
- Agent memory view
- Notifications
- Kill switch

All execution, planning, memory, permissions, notifications, observations, and desktop presence are scripted locally.

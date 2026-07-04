# Voice

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

Voice mode lets users command Cove from the desktop. It is disabled by default and must be manually enabled.

## Enablement Policy

Voice mode requires one of:

- Bluetooth headset
- Trusted microphone

## Supported Voice Output

Cove should allow:

- Male voices
- Female voices
- Future voice cloning with explicit consent and separate controls

## Pipeline

```text
Wake or push-to-talk
  -> Audio capture
  -> Optional voice verification
  -> Speech-to-text
  -> Intent parsing
  -> Context attachment
  -> Permission evaluation
  -> Execution dispatch
  -> Spoken or visual response
```

## Safety Rules

- Show a recording indicator whenever audio is captured.
- Support cancellation and correction.
- Never let voice bypass the permission broker.
- Disable capture immediately when kill switch is active.

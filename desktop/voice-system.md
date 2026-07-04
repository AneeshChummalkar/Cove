# Voice System

The voice system is an optional command interface for Cove. It is disabled by default and must be manually enabled.

## Enablement

Voice mode requires one of:

- Bluetooth headset
- Trusted microphone

Voice output should support male voices, female voices, and future voice cloning with explicit consent.

## Pipeline

1. Wake word or push-to-talk
2. Microphone capture
3. Optional voice identification
4. Speech-to-text
5. Intent parsing
6. Context attachment
7. Permission evaluation
8. Execution dispatch
9. Spoken or visual response

## Requirements

- Visible recording indicator
- Low-latency response
- Cancel and correction support
- Push-to-talk fallback
- Local-first wake handling
- Clear microphone permission state

## Failure Handling

Cove should ask for clarification when speech confidence is low, when the target app or contact is ambiguous, or when the requested action is sensitive.

# Identity Confidence System

Status: architecture specification only. No production code, APIs, or biometric implementation are defined here.

## Purpose

Identity confidence estimates whether Cove is operating for the trusted user on a trusted session. It combines device, voice, face, and session signals to decide whether autonomous behavior is allowed.

## Inputs

- Trusted device confidence
- Face verification confidence
- Voice verification confidence
- Session confidence

Example:

```text
Device:
100%

Voice:
92%

Face:
95%

Total:
96%
```

## Confidence Signals

Trusted device confidence:

- Current desktop is trusted.
- Device has not been revoked.
- Secure storage and local account state are valid.

Voice verification confidence:

- Voice matches an enrolled profile.
- Input came from a trusted microphone or Bluetooth headset.
- Speech command was recent and clear.

Face verification confidence:

- Face matches an enrolled profile.
- User presence is recent.
- Session has not changed since verification.

Session confidence:

- OS session is unlocked.
- No user switch occurred.
- Device has not slept too long.
- Cove has not been idle beyond the configured threshold.

## Scoring Model

Identity confidence should return:

- Device score
- Voice score
- Face score
- Session score
- Total score
- Missing signals
- Confidence reason
- Required next verification step

The total score should be weighted by active mode and action sensitivity. For example, voice may matter more for voice-triggered actions, while session confidence may matter more for background agents.

## Confidence Bands

| Total Confidence | Behavior |
| --- | --- |
| 95% to 100% | Full trusted state inside current permission mode. |
| 85% to 94% | Allow low-risk actions; confirm important actions. |
| 70% to 84% | Disable Autonomous mode and require confirmation. |
| Below 70% | Pause sensitive activity and trigger security review. |

## Rules If Confidence Falls

If confidence falls, Cove should:

- Disable Autonomous mode.
- Require confirmation.
- Trigger security review.
- Pause background agents when needed.
- Stop voice-triggered execution if voice confidence is low.
- Request face or voice re-verification when appropriate.
- Write activity and audit events.

## Permission Interaction

Identity confidence does not replace permission mode. It constrains permission mode.

Examples:

- Autonomous mode plus low confidence becomes Balanced or Safe behavior.
- Balanced mode plus low confidence requires confirmation for more actions.
- Safe mode plus very low confidence may deny execution until re-verification.

## Trust Rule

The user should be able to see why Cove trusts the current session and what changed when confidence drops.

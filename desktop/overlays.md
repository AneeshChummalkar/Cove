# Overlays

Cove overlays provide local presence for the runtime without turning the website into a control center.

## Surfaces

- Wake indicator
- Voice capture panel
- Command preview
- Permission prompt
- Agent status strip
- Error recovery panel
- Kill switch control

## Design Rules

- Keep overlays small and dismissible
- Show recording state clearly
- Show the exact action before sensitive execution
- Provide stop, deny, and pause controls
- Avoid blocking the user's current work

## Overlay Events

Overlays can emit:

- User confirmed action
- User denied action
- User paused agent
- User stopped runtime
- User corrected transcript
- User changed permission mode


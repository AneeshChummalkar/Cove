# Voice Recognition

Voice recognition is an optional future identity layer separate from speech-to-text.

## Uses

- Verify who issued a command
- Gate important actions
- Detect unknown speakers
- Support multiple trusted users

## Requirements

- Explicit enrollment
- Clear confidence thresholds
- Recovery path for false rejection
- Local-first matching where practical
- No irreversible action based only on voice confidence

## Relationship to Permissions

Voice identity can raise or lower confidence, but the permission broker remains the final decision point for every action.


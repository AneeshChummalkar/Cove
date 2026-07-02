# Permissions

The permission system is the core trust layer for Cove.

## Modes

- Ask every action
- Ask important actions only
- Fully autonomous

## Permission Broker

The broker receives a proposed action and returns one of:

- Allow
- Ask user
- Deny
- Pause agent
- Trigger security review

## Evaluation Inputs

- Permission mode
- Task or agent scope
- Action sensitivity
- App sensitivity
- Data sensitivity
- Identity confidence
- Device trust status
- Reversibility
- Recent failures

## Important Actions

Important actions include sending messages, deleting files, sharing private data, making purchases, changing security settings, installing software, granting access, and modifying persistent memory.


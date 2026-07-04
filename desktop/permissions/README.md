# Permissions

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

The permission system is Cove's central trust layer. Every proposed task, agent step, memory write, app control action, and sensitive observation passes through it.

## Modes

- Safe
- Balanced
- Autonomous

## Broker Decisions

The permission broker may return:

- Allow
- Ask user
- Deny
- Pause agent
- Trigger security review

## Inputs

- Permission mode
- Task or agent scope
- Action sensitivity
- App sensitivity
- Data sensitivity
- Reversibility
- Identity confidence
- Device trust status
- Recent failures
- Audit history

## Important Actions

Important actions include sending messages, deleting files, sharing private data, making purchases, changing security settings, installing software, granting new access, and modifying persistent memory.

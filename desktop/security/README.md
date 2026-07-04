# Security

Status: architecture placeholder. No production code belongs here during Phase 3.

## Purpose

Security protects local runtime execution, user identity, sensitive memory, auditability, and emergency shutdown.

## Required Capabilities

- Face verification
- Voice verification
- Encryption
- Audit logs
- Kill switch
- Device trust
- Session lock awareness
- Sensitive action classification

## Kill Switch Scope

The kill switch immediately pauses:

- Voice capture
- Screen observation
- Task execution
- Agent execution
- Tool access
- Cloud sync
- New permission grants
- Background planning

## Audit Log

Audit logs should capture actor, target, permission mode, decision, action, result, timestamp, identity confidence, and device identity.

# Cove Backend Architecture

The backend supports the desktop runtime and website. It is not the product surface.

## Responsibilities

- Account authentication
- Device registration
- Cloud sync coordination
- Security settings
- Download metadata
- Documentation hosting support
- Optional encrypted memory sync
- Audit log backup when enabled

## Non-Goals

- No chatbot interface
- No AI SaaS dashboard
- No primary agent control center
- No replacement for the desktop runtime

## Core Services

### Identity Service

Manages accounts, sessions, recovery, and trusted devices.

### Device Service

Registers Windows and macOS installations, tracks trust status, and supports revocation.

### Sync Service

Coordinates optional encrypted sync for settings, selected memory, and agent metadata.

### Security Service

Stores account-level security preferences, kill switch state, device verification requirements, and audit retention settings.

### Download Service

Serves release metadata for stable, beta, Windows, and macOS builds.

## Security Requirements

- Encrypt sensitive data in transit
- Prefer end-to-end encryption for synced memory
- Separate device tokens from account sessions
- Support immediate device revocation
- Support global kill switch
- Avoid storing raw voice or face identity data by default


# Cove

Cove is a desktop-first personal AI runtime that lives on a user's computer.

The desktop runtime is the product. The website exists only to help users download Cove, manage their account, manage devices, configure cloud sync, review security settings, and read documentation.

Cove is not an AI SaaS dashboard, an agent dashboard, or a chatbot website.

## Core Principles

- Voice-first
- Desktop-first
- Privacy-first
- Permission-first
- Human-centered
- Persistent memory
- Background execution
- Agent mode
- Task mode
- Windows support
- macOS support
- Security-first

## Repository Structure

```text
cove/
  README.md
  VISION.md
  website/
  desktop/
  backend/
  docs/
  research/
```

## Product Surfaces

### Desktop Runtime

The Cove desktop app runs locally on Windows and macOS. It listens for user intent, understands the active desktop context with permission, executes short tasks, and hosts persistent agents.

### Website

The Cove website supports the runtime. It provides downloads, account management, device management, cloud sync, security settings, and documentation.

## Modes

### Task Mode

Task mode handles immediate, bounded commands.

Examples:

- "Open YouTube"
- "Text Sam"
- "Reply to email"

### Agent Mode

Agent mode creates persistent agents that can monitor, plan, and execute over time within the user's permission settings.

Examples:

- "Track AI news"
- "Manage Gmail"
- "Review resumes"
- "Plan trip"

## Permission Levels

Cove supports three operating levels:

- Ask every action
- Ask important actions only
- Fully autonomous

## Security Roadmap

Cove is designed to support:

- Voice identification
- Face identification
- Device verification
- Audit logs
- Kill switch

## Getting Started

Install website dependencies:

```bash
cd website
npm install
```

Run the website:

```bash
npm run dev
```


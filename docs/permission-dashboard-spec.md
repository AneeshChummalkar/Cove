# Permission Dashboard Specification

Status: architecture specification only.

## Permission Modes

Cove exposes three user-facing modes:

| Mode | Meaning | Default Use |
| --- | --- | --- |
| Safe | Ask before most actions and all sensitive actions. | New users, new devices, sensitive work. |
| Balanced | Allow low-risk actions and ask for important actions. | Recommended everyday default. |
| Autonomous | Allow actions inside explicit agent or task scope, with hard safety boundaries. | Trusted workflows and narrowly scoped agents. |

## Dashboard Goals

The dashboard answers three questions:

- What can Cove see?
- What can Cove remember?
- What can Cove control?

## Dashboard Sections

### Current Mode

Shows the active permission mode, the reason it was selected, and a control to change it.

Required states:

- Safe
- Balanced
- Autonomous
- Temporarily elevated
- Paused by kill switch
- Locked because identity confidence is low

### App Visibility

Shows apps and surfaces Cove can observe.

Allowed categories:

- Desktop
- Browser
- Gmail
- YouTube
- WhatsApp
- Discord
- VS Code
- Other user-approved applications

Restricted by default:

- Password managers
- Banking apps
- Incognito tabs
- Private browsing windows
- Security settings
- Credential prompts

### App Control

Shows apps Cove can operate and the approved action classes for each.

Example action classes:

- Open or focus app
- Read visible content
- Draft content
- Send content
- Click UI controls
- Download files
- Modify files
- Install or update software

### Agents

Shows active, paused, completed, and failed agents.

Each agent row must include:

- Name
- Goal
- Scope
- Permission mode
- Tool access
- Last action
- Next planned action
- Pause and terminate controls

### Memory

Shows memory categories and controls.

Categories:

- Preferences
- Contacts
- Writing style
- Voice profile
- Workflows
- Agents
- History
- Trusted devices

Required controls:

- Inspect
- Edit
- Delete
- Export
- Disable
- Selective sync

### Devices

Shows trusted devices and input devices.

Tracked device types:

- Current desktop
- Bluetooth headset
- Trusted microphone
- Camera used for face verification

Required controls:

- Trust device
- Rename device
- Revoke device
- Require re-verification

## Decision Outcomes

The permission broker may return:

- Allow
- Ask user
- Deny
- Pause agent
- Trigger security review

Every decision must create an audit event, including denied actions.

## Important Actions

Important actions include:

- Sending messages
- Deleting files
- Sharing private data
- Making purchases
- Applying to jobs or internships
- Changing security settings
- Installing software
- Granting new access
- Modifying persistent memory
- Acting in password, banking, or private browsing contexts

## Required UX Guarantees

- Sensitive actions must name the exact action and target before approval.
- Permission prompts must include allow once, deny, and pause controls.
- Autonomous mode must show active scope boundaries.
- Revocation must stop future actions immediately.
- The dashboard must be reachable from every persistent Cove surface.

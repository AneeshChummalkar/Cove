# Architecture Diagrams

Status: architecture specification only. Diagrams use Mermaid so they can render in Markdown viewers that support it.

## High-Level Runtime

```mermaid
flowchart TD
  User[User] --> UI[Desktop UI and Overlays]
  UI --> Runtime[Runtime Core]
  Runtime --> ModeRouter[Mode Router]
  ModeRouter --> TaskEngine[Task Engine]
  ModeRouter --> AgentEngine[Agent Engine]
  Runtime --> PermissionBroker[Permission Broker]
  Runtime --> Memory[Memory Service]
  Runtime --> Security[Security Service]
  Runtime --> Notifications[Notification Service]
  TaskEngine --> Integrations[Integrations]
  AgentEngine --> Integrations
  Integrations --> OSAdapters[OS Adapters]
  OSAdapters --> Apps[Desktop Apps and Browser]
  PermissionBroker --> ActivityLog[Activity Log]
  Security --> AuditLog[Security Audit Log]
```

## Task Mode Flow

```mermaid
sequenceDiagram
  participant U as User
  participant O as Overlay
  participant R as Runtime
  participant P as Permission Broker
  participant T as Task Engine
  participant A as App Adapter
  participant L as Activity Log

  U->>O: "Cove open Spotify"
  O->>R: command transcript
  R->>R: parse intent
  R->>P: evaluate app launch
  P-->>R: allow
  R->>T: execute task
  T->>A: launch app
  A-->>T: result
  T-->>O: completion
  R->>L: write task event
```

## Agent Mode Flow

```mermaid
sequenceDiagram
  participant U as User
  participant R as Runtime
  participant P as Planner
  participant A as Agent
  participant M as Memory
  participant B as Permission Broker
  participant N as Notifications
  participant L as Activity Log

  U->>R: goal
  R->>P: create plan
  P-->>R: scoped plan
  R->>B: request initial permission
  B-->>R: approval required or allow
  R->>A: create agent
  A->>M: create namespace
  loop background execution
    A->>B: evaluate next action
    B-->>A: allow, ask, deny, or pause
    A->>L: write step event
  end
  A->>N: completion or approval needed
```

## Permission Decision

```mermaid
flowchart TD
  Action[Proposed Action] --> Classify[Classify Sensitivity]
  Classify --> Mode{Permission Mode}
  Mode --> Safe[Safe]
  Mode --> Balanced[Balanced]
  Mode --> Autonomous[Autonomous]
  Safe --> AskAll[Ask for nearly every action]
  Balanced --> AskImportant[Ask for important actions]
  Autonomous --> Policy[Allow within explicit scope]
  AskAll --> Decision{Decision}
  AskImportant --> Decision
  Policy --> Decision
  Decision --> Allow[Allow]
  Decision --> Ask[Ask User]
  Decision --> Deny[Deny]
  Decision --> Pause[Pause Agent]
  Decision --> Log[Write Audit Event]
```

## Screen Understanding Boundary

```mermaid
flowchart LR
  Screen[Screen Context] --> Policy[Visibility Policy]
  Policy --> Allowed[Allowed Sources]
  Policy --> Restricted[Restricted By Default]
  Allowed --> Desktop[Desktop]
  Allowed --> Browser[Browser]
  Allowed --> Gmail[Gmail]
  Allowed --> YouTube[YouTube]
  Allowed --> WhatsApp[WhatsApp]
  Allowed --> Discord[Discord]
  Allowed --> VSCode[VS Code]
  Allowed --> Apps[Applications]
  Restricted --> Passwords[Password Managers]
  Restricted --> Banking[Banking Apps]
  Restricted --> Incognito[Incognito Tabs]
```

## Trust Surface

```mermaid
flowchart TD
  Runtime[Runtime Core] --> Sees[What Cove Sees]
  Runtime --> Remembers[What Cove Remembers]
  Runtime --> Controls[What Cove Controls]
  Runtime --> Acting[What Is Acting Now]
  Sees --> Dashboard[Trust Dashboard]
  Remembers --> Dashboard
  Controls --> Dashboard
  Acting --> Dashboard
  Dashboard --> ActivityLog[Activity Log]
  Dashboard --> KillSwitch[Kill Switch]
  Dashboard --> PermissionControls[Permission Controls]
```

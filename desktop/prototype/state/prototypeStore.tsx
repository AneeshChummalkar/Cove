import { createContext, ReactNode, useContext, useEffect, useMemo, useReducer } from "react";
import fakeData from "../data/fake-data.json";

export type PresenceMode = "GHOST" | "ASSISTANT" | "COMPANION" | "AGENTIC";
export type PermissionMode = "SAFE" | "BALANCED" | "AUTONOMOUS";
export type RuntimeStatus = "idle" | "listening" | "thinking" | "task" | "agent" | "permission" | "paused";
type WorkStatus = "idle" | "planning" | "running" | "permission" | "paused" | "complete" | "denied";

export interface TaskRun {
  id: string;
  title: string;
  target: string;
  description: string;
  requiresPermission: boolean;
  permissionAction?: string;
  reason: string;
  completion: string;
  status: WorkStatus;
  progress: number;
}

export interface AgentRun {
  id: string;
  name: string;
  goal: string;
  scope: string;
  memoryNamespace: string;
  requiresPermissionAt: number;
  permissionAction: string;
  target: string;
  stages: string[];
  status: WorkStatus;
  progress: number;
  stageIndex: number;
  permissionRequested: boolean;
}

export interface ActivityEvent {
  time: string;
  title: string;
  detail: string;
  why: string;
  permission: string;
  memory: string;
}

export interface NotificationItem {
  id: string;
  title: string;
  body: string;
  tone: "info" | "success" | "warning" | "critical";
}

export interface PermissionDialogState {
  source: "task" | "agent";
  id: string;
  action: string;
  target: string;
  mode: PermissionMode;
  reason: string;
}

export interface OrbPosition {
  x: number;
  y: number;
}

export interface PrototypeState {
  presenceMode: PresenceMode;
  permissionMode: PermissionMode;
  runtimeStatus: RuntimeStatus;
  tasks: TaskRun[];
  agents: AgentRun[];
  activeTaskId: string;
  activeAgentId: string;
  activityLog: ActivityEvent[];
  notifications: NotificationItem[];
  permissionDialog: PermissionDialogState | null;
  memory: Record<string, string[]>;
  cursorContextId: string;
  killSwitch: boolean;
  orbExpanded: boolean;
  orbPosition: OrbPosition;
  tick: number;
}

type Action =
  | { type: "SET_PRESENCE"; mode: PresenceMode }
  | { type: "SET_PERMISSION"; mode: PermissionMode }
  | { type: "START_TASK"; id: string }
  | { type: "START_AGENT"; id: string }
  | { type: "TICK" }
  | { type: "RESOLVE_PERMISSION"; decision: "allow" | "deny" | "pause" }
  | { type: "DISMISS_NOTIFICATION"; id: string }
  | { type: "SET_CURSOR_CONTEXT"; id: string }
  | { type: "TOGGLE_ORB" }
  | { type: "SET_ORB_POSITION"; position: OrbPosition }
  | { type: "KILL_SWITCH" }
  | { type: "RESET_SIMULATION" };

const nowLabel = () =>
  new Intl.DateTimeFormat("en-US", {
    hour: "numeric",
    minute: "2-digit"
  }).format(new Date());

const makeId = (prefix: string, tick: number) => `${prefix}-${tick}-${Math.random().toString(16).slice(2, 7)}`;

const baseTasks: TaskRun[] = fakeData.tasks.map((task) => ({
  ...task,
  status: "idle",
  progress: 0
}));

const baseAgents: AgentRun[] = fakeData.agents.map((agent) => ({
  ...agent,
  status: "idle",
  progress: 0,
  stageIndex: 0,
  permissionRequested: false
}));

const initialState: PrototypeState = {
  presenceMode: "ASSISTANT",
  permissionMode: "BALANCED",
  runtimeStatus: "idle",
  tasks: baseTasks,
  agents: baseAgents,
  activeTaskId: baseTasks[0].id,
  activeAgentId: baseAgents[0].id,
  activityLog: fakeData.activityLog,
  notifications: [
    {
      id: "welcome",
      title: "Cove prototype ready",
      body: "Everything here is simulated with local state.",
      tone: "info"
    }
  ],
  permissionDialog: null,
  memory: fakeData.memory,
  cursorContextId: "pdf",
  killSwitch: false,
  orbExpanded: true,
  orbPosition: { x: 1020, y: 610 },
  tick: 0
};

function addActivity(state: PrototypeState, event: Omit<ActivityEvent, "time">): ActivityEvent[] {
  return [{ time: nowLabel(), ...event }, ...state.activityLog].slice(0, 18);
}

function addNotification(
  state: PrototypeState,
  notification: Omit<NotificationItem, "id">,
  force = false
): NotificationItem[] {
  if (state.presenceMode === "GHOST" && !force) {
    return state.notifications;
  }

  const limit = state.presenceMode === "AGENTIC" ? 5 : state.presenceMode === "COMPANION" ? 4 : 3;
  return [{ id: makeId("notice", state.tick), ...notification }, ...state.notifications].slice(0, limit);
}

function deriveRuntimeStatus(state: PrototypeState): RuntimeStatus {
  if (state.killSwitch) {
    return "paused";
  }
  if (state.permissionDialog) {
    return "permission";
  }
  if (state.agents.some((agent) => agent.status === "running" || agent.status === "planning")) {
    return "agent";
  }
  if (state.tasks.some((task) => task.status === "running" || task.status === "planning")) {
    return "task";
  }
  if (state.tick % 11 === 0) {
    return "listening";
  }
  if (state.tick % 7 === 0) {
    return "thinking";
  }
  return "idle";
}

function startTask(state: PrototypeState, id: string): PrototypeState {
  if (state.killSwitch) {
    return state;
  }

  const task = state.tasks.find((item) => item.id === id);
  if (!task) {
    return state;
  }

  const asksInMode = state.permissionMode === "SAFE" || task.requiresPermission;
  const tasks: TaskRun[] = state.tasks.map((item) =>
    item.id === id
      ? { ...item, status: asksInMode ? "permission" : "running", progress: asksInMode ? 0 : 16 }
      : item
  );

  const next: PrototypeState = {
    ...state,
    tasks,
    activeTaskId: id,
    runtimeStatus: asksInMode ? "permission" : "task",
    permissionDialog: asksInMode
      ? {
          source: "task",
          id,
          action: task.permissionAction || task.title,
          target: task.target,
          mode: state.permissionMode,
          reason: task.reason
        }
      : null,
    activityLog: addActivity(state, {
      title: asksInMode ? "Requested Permission" : `Started ${task.title}`,
      detail: asksInMode ? `Task Mode paused before ${task.title}.` : `Task Mode is simulating ${task.title}.`,
      why: task.description,
      permission: asksInMode ? `${state.permissionMode} asks before this action.` : `${state.permissionMode} allowed this simulated action.`,
      memory: "No real data read. Prototype state only."
    })
  };

  return {
    ...next,
    notifications: addNotification(next, {
      title: asksInMode ? "Permission required" : `${task.title} running`,
      body: asksInMode ? `${task.permissionAction || task.title} needs approval.` : task.description,
      tone: asksInMode ? "warning" : "info"
    }, asksInMode)
  };
}

function startAgent(state: PrototypeState, id: string): PrototypeState {
  if (state.killSwitch) {
    return state;
  }

  const agent = state.agents.find((item) => item.id === id);
  if (!agent) {
    return state;
  }

  const agents: AgentRun[] = state.agents.map((item) =>
    item.id === id
      ? { ...item, status: "planning", progress: 8, stageIndex: 0, permissionRequested: false }
      : item
  );

  const next: PrototypeState = {
    ...state,
    agents,
    activeAgentId: id,
    runtimeStatus: "agent",
    memory: {
      ...state.memory,
      Agents: Array.from(new Set([agent.name, ...state.memory.Agents]))
    },
    activityLog: addActivity(state, {
      title: `Created ${agent.name}`,
      detail: "Agent Mode created a simulated persistent agent.",
      why: agent.goal,
      permission: `${state.permissionMode} allowed scoped planning only.`,
      memory: `Created fake namespace ${agent.memoryNamespace}.`
    }),
    notifications: addNotification(state, {
      title: `${agent.name} planning`,
      body: agent.scope,
      tone: "info"
    })
  };

  return next;
}

function tick(state: PrototypeState): PrototypeState {
  if (state.killSwitch) {
    return { ...state, tick: state.tick + 1, runtimeStatus: "paused" };
  }

  let next = { ...state, tick: state.tick + 1 };
  let activityLog = next.activityLog;
  let notifications = next.notifications;
  let memory = next.memory;
  let permissionDialog = next.permissionDialog;

  const tasks: TaskRun[] = next.tasks.map((task) => {
    if (task.status !== "running" && task.status !== "planning") {
      return task;
    }

    const progress = Math.min(100, task.progress + 18);
    if (progress >= 100) {
      activityLog = addActivity({ ...next, activityLog }, {
        title: `Completed ${task.title}`,
        detail: task.completion,
        why: "The scripted Task Mode flow reached completion.",
        permission: `${next.permissionMode} permission boundary was respected.`,
        memory: task.id === "summarize-pdf" ? "Added fake PDF summary to History." : "No persistent memory changed."
      });
      notifications = addNotification({ ...next, notifications, tick: next.tick }, {
        title: `${task.title} complete`,
        body: task.completion,
        tone: "success"
      });
      if (task.id === "summarize-pdf") {
        memory = {
          ...memory,
          History: Array.from(new Set(["PDF summarized into 5 bullets", ...memory.History]))
        };
      }
      return { ...task, progress, status: "complete" };
    }

    return { ...task, progress, status: "running" };
  });

  const agents: AgentRun[] = next.agents.map((agent) => {
    if (agent.status !== "running" && agent.status !== "planning") {
      return agent;
    }

    const stepSize = agent.status === "planning" ? 10 : 12;
    const progress = Math.min(100, agent.progress + stepSize);
    const stageIndex = Math.min(agent.stages.length - 1, Math.floor((progress / 100) * agent.stages.length));
    const shouldAsk =
      agent.requiresPermissionAt > 0 &&
      !agent.permissionRequested &&
      progress >= agent.requiresPermissionAt &&
      next.permissionMode !== "AUTONOMOUS";

    if (shouldAsk) {
      permissionDialog = {
        source: "agent",
        id: agent.id,
        action: agent.permissionAction,
        target: agent.target,
        mode: next.permissionMode,
        reason: "Agent reached a boundary that changes external state or memory."
      };
      activityLog = addActivity({ ...next, activityLog }, {
        title: "Requested Permission",
        detail: `${agent.name} needs approval for ${agent.permissionAction}.`,
        why: agent.goal,
        permission: `${next.permissionMode} pauses important agent actions.`,
        memory: "No new memory written until approval."
      });
      notifications = addNotification({ ...next, notifications, tick: next.tick }, {
        title: "Agent needs approval",
        body: `${agent.permissionAction} for ${agent.target}`,
        tone: "warning"
      }, true);
      return { ...agent, progress, stageIndex, status: "permission", permissionRequested: true };
    }

    if (progress >= 100) {
      activityLog = addActivity({ ...next, activityLog }, {
        title: `${agent.name} completed`,
        detail: agent.stages[agent.stages.length - 1],
        why: agent.goal,
        permission: `${next.permissionMode} allowed the scoped fake agent run.`,
        memory: `Updated ${agent.memoryNamespace} with fake progress state.`
      });
      notifications = addNotification({ ...next, notifications, tick: next.tick }, {
        title: `${agent.name} complete`,
        body: agent.goal,
        tone: "success"
      });
      memory = {
        ...memory,
        History: Array.from(new Set([`${agent.name} completed a simulated run`, ...memory.History]))
      };
      return { ...agent, progress, stageIndex, status: "complete" };
    }

    return { ...agent, progress, stageIndex, status: progress < 28 ? "planning" : "running" };
  });

  next = {
    ...next,
    tasks,
    agents,
    memory,
    activityLog,
    notifications,
    permissionDialog
  };

  return { ...next, runtimeStatus: deriveRuntimeStatus(next) };
}

function resolvePermission(state: PrototypeState, decision: "allow" | "deny" | "pause"): PrototypeState {
  const dialog = state.permissionDialog;
  if (!dialog) {
    return state;
  }

  const allowed = decision === "allow";
  const paused = decision === "pause";
  const status: WorkStatus = allowed ? "running" : paused ? "paused" : "denied";

  const tasks = state.tasks.map((task) =>
    dialog.source === "task" && task.id === dialog.id ? { ...task, status, progress: allowed ? 14 : task.progress } : task
  );

  const agents = state.agents.map((agent) =>
    dialog.source === "agent" && agent.id === dialog.id ? { ...agent, status, progress: allowed ? agent.progress : agent.progress } : agent
  );

  const next: PrototypeState = {
    ...state,
    tasks,
    agents,
    permissionDialog: null,
    activityLog: addActivity(state, {
      title: allowed ? "Permission Allowed Once" : paused ? "Agent Paused" : "Permission Denied",
      detail: `${dialog.action} on ${dialog.target}.`,
      why: dialog.reason,
      permission: `${dialog.mode} decision: ${decision}.`,
      memory: allowed ? "Decision stored in fake audit history." : "No memory changed."
    })
  };

  return {
    ...next,
    runtimeStatus: deriveRuntimeStatus(next),
    notifications: addNotification(next, {
      title: allowed ? "Permission allowed once" : paused ? "Agent paused" : "Permission denied",
      body: `${dialog.action} - ${dialog.target}`,
      tone: allowed ? "success" : paused ? "warning" : "critical"
    }, true)
  };
}

function reducer(state: PrototypeState, action: Action): PrototypeState {
  switch (action.type) {
    case "SET_PRESENCE": {
      const next = {
        ...state,
        presenceMode: action.mode,
        activityLog: addActivity(state, {
          title: `Presence changed to ${fakeData.presenceModes[action.mode].label}`,
          detail: fakeData.presenceModes[action.mode].desktopPresence,
          why: "User changed how visible Cove should feel.",
          permission: "Presence does not grant new permissions.",
          memory: "Preference changed in local prototype state."
        })
      };
      return {
        ...next,
        notifications: addNotification(next, {
          title: `${fakeData.presenceModes[action.mode].label} mode`,
          body: fakeData.presenceModes[action.mode].popupFrequency,
          tone: "info"
        }, action.mode !== "GHOST")
      };
    }
    case "SET_PERMISSION":
      return {
        ...state,
        permissionMode: action.mode,
        activityLog: addActivity(state, {
          title: `Permission changed to ${fakeData.permissionModes[action.mode].label}`,
          detail: fakeData.permissionModes[action.mode].description,
          why: "User changed the approval boundary.",
          permission: "Future fake actions use this mode.",
          memory: "Preference changed in local prototype state."
        })
      };
    case "START_TASK":
      return startTask(state, action.id);
    case "START_AGENT":
      return startAgent(state, action.id);
    case "TICK":
      return tick(state);
    case "RESOLVE_PERMISSION":
      return resolvePermission(state, action.decision);
    case "DISMISS_NOTIFICATION":
      return { ...state, notifications: state.notifications.filter((notice) => notice.id !== action.id) };
    case "SET_CURSOR_CONTEXT":
      return { ...state, cursorContextId: action.id };
    case "TOGGLE_ORB":
      return { ...state, orbExpanded: !state.orbExpanded };
    case "SET_ORB_POSITION":
      return { ...state, orbPosition: action.position };
    case "KILL_SWITCH":
      return {
        ...state,
        killSwitch: true,
        runtimeStatus: "paused",
        permissionDialog: null,
        tasks: state.tasks.map((task) =>
          task.status === "running" || task.status === "planning" || task.status === "permission"
            ? { ...task, status: "paused" }
            : task
        ),
        agents: state.agents.map((agent) =>
          agent.status === "running" || agent.status === "planning" || agent.status === "permission"
            ? { ...agent, status: "paused" }
            : agent
        ),
        notifications: [
          {
            id: makeId("paused", state.tick),
            title: "Cove paused",
            body: "Tasks, agents, notifications, and observations stopped.",
            tone: "critical"
          }
        ],
        activityLog: addActivity(state, {
          title: "Kill Switch Activated",
          detail: "Cove paused.",
          why: "User stopped all prototype activity.",
          permission: "All fake execution revoked immediately.",
          memory: "No additional observations or writes."
        })
      };
    case "RESET_SIMULATION":
      return {
        ...initialState,
        tick: state.tick + 1,
        orbPosition: state.orbPosition
      };
    default:
      return state;
  }
}

const CovePrototypeContext = createContext<{
  state: PrototypeState;
  data: typeof fakeData;
  dispatch: React.Dispatch<Action>;
} | null>(null);

export function CovePrototypeProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(reducer, initialState);

  useEffect(() => {
    const timer = window.setInterval(() => dispatch({ type: "TICK" }), 1800);
    return () => window.clearInterval(timer);
  }, []);

  const value = useMemo(() => ({ state, data: fakeData, dispatch }), [state]);

  return <CovePrototypeContext.Provider value={value}>{children}</CovePrototypeContext.Provider>;
}

export function useCovePrototype() {
  const context = useContext(CovePrototypeContext);
  if (!context) {
    throw new Error("useCovePrototype must be used inside CovePrototypeProvider");
  }
  return context;
}

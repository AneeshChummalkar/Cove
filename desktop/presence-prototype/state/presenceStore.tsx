import { createContext, ReactNode, useContext, useMemo, useState } from "react";

export type Platform = "mac" | "windows";
export type PermissionMode = "Safe" | "Balanced" | "Autonomous";
export type PresenceMode = "Ghost" | "Assistant" | "Companion" | "Agentic";
export type RuntimeStatus =
  | "idle"
  | "listening"
  | "text"
  | "thinking"
  | "task"
  | "agent"
  | "permission"
  | "notification";

export type AppContext = "PDF" | "YouTube" | "Gmail" | "VSCode" | "WhatsApp" | "Trading" | "Desktop";
export type AgentStage = "planning" | "running" | "paused" | "completed";

export type ActivityItem = {
  id: number;
  time: string;
  title: string;
  detail: string;
};

export type Toast = {
  id: number;
  tone: "complete" | "permission" | "risk" | "security";
  title: string;
  detail: string;
};

export type PermissionRequest = {
  title: string;
  app: string;
  action: string;
  reason: string;
  preview: string;
  risk: "low" | "medium" | "high";
  onAllow: () => void;
};

type SetupDraft = {
  permissionMode: PermissionMode;
  presenceMode: PresenceMode;
  voiceEnabled: boolean;
  launchOnStartup: boolean;
  appAccess: string[];
};

type PresenceState = {
  platform: Platform;
  status: RuntimeStatus;
  message: string;
  setupComplete: boolean;
  permissionMode: PermissionMode;
  presenceMode: PresenceMode;
  voiceEnabled: boolean;
  audioDeviceConnected: boolean;
  launchOnStartup: boolean;
  appAccess: string[];
  agentAccess: boolean;
  memoryEnabled: boolean;
  notificationsEnabled: boolean;
  trustedDevices: string[];
  privacy: {
    paused: boolean;
    screenObservation: boolean;
    suggestions: boolean;
    privateMode: boolean;
    offForApp: boolean;
    offForVideo: boolean;
    killSwitch: boolean;
  };
  currentApp: AppContext;
  commandText: string;
  activeAgent: string | null;
  agentStage: AgentStage | null;
  agentProgress: number;
  activeTask: string | null;
  permissionRequest: PermissionRequest | null;
  toasts: Toast[];
  activity: ActivityItem[];
  settingsOpen: boolean;
  activityOpen: boolean;
  setupDraft: SetupDraft;
  remembers: string[];
  controls: string[];
};

type PresenceActions = {
  setPlatform: (platform: Platform) => void;
  setCurrentApp: (app: AppContext) => void;
  setCommandText: (value: string) => void;
  completeSetup: () => void;
  updateSetup: (draft: Partial<SetupDraft>) => void;
  toggleSetupAccess: (app: string) => void;
  runCommand: (raw: string) => void;
  runTask: (task: string) => void;
  runAgent: (agent: string) => void;
  pauseAgent: () => void;
  stopAgent: () => void;
  approvePermission: () => void;
  denyPermission: () => void;
  openSettings: () => void;
  closeSettings: () => void;
  toggleActivity: () => void;
  dismissToast: (id: number) => void;
  updatePermissionMode: (mode: PermissionMode) => void;
  updatePresenceMode: (mode: PresenceMode) => void;
  toggleVoice: () => void;
  toggleAudioDevice: () => void;
  toggleAppAccess: (app: string) => void;
  toggleAgentAccess: () => void;
  toggleMemory: () => void;
  toggleNotifications: () => void;
  togglePrivacy: (key: keyof PresenceState["privacy"]) => void;
  collapse: () => void;
};

const appAccessOptions = [
  "Browser",
  "Gmail",
  "Spotify",
  "WhatsApp",
  "YouTube",
  "Discord",
  "Reddit",
  "X",
  "VSCode",
  "Files",
  "Settings"
];

const initialActivity: ActivityItem[] = [
  { id: 1, time: "10:02 PM", title: "Opened Spotify", detail: "Fast task, no agent created." },
  { id: 2, time: "10:05 PM", title: "Created Email Agent", detail: "Scoped to Gmail cleanup simulation." },
  { id: 3, time: "10:07 PM", title: "Permission requested", detail: "WhatsApp send required approval." },
  { id: 4, time: "10:08 PM", title: "Agent completed", detail: "Filtered email sample set." }
];

const initialState: PresenceState = {
  platform: "mac",
  status: "idle",
  message: "Cove",
  setupComplete: false,
  permissionMode: "Balanced",
  presenceMode: "Assistant",
  voiceEnabled: true,
  audioDeviceConnected: true,
  launchOnStartup: true,
  appAccess: ["Browser", "Gmail", "Spotify", "WhatsApp", "YouTube", "VSCode"],
  agentAccess: true,
  memoryEnabled: true,
  notificationsEnabled: true,
  trustedDevices: ["MacBook Pro", "AirPods Pro"],
  privacy: {
    paused: false,
    screenObservation: true,
    suggestions: true,
    privateMode: false,
    offForApp: false,
    offForVideo: false,
    killSwitch: false
  },
  currentApp: "Desktop",
  commandText: "",
  activeAgent: null,
  agentStage: null,
  agentProgress: 0,
  activeTask: null,
  permissionRequest: null,
  toasts: [],
  activity: initialActivity,
  settingsOpen: false,
  activityOpen: false,
  setupDraft: {
    permissionMode: "Balanced",
    presenceMode: "Assistant",
    voiceEnabled: true,
    launchOnStartup: true,
    appAccess: ["Browser", "Gmail", "Spotify", "WhatsApp", "YouTube", "VSCode"]
  },
  remembers: ["Sudharshan is a WhatsApp contact alias.", "You prefer brief summaries.", "Ask before sending messages."],
  controls: ["Spotify", "YouTube", "WhatsApp", "Gmail", "Discord", "VSCode"]
};

const PresenceContext = createContext<{ state: PresenceState; actions: PresenceActions } | null>(null);

const now = () =>
  new Intl.DateTimeFormat("en-US", {
    hour: "numeric",
    minute: "2-digit"
  }).format(new Date());

const lower = (value: string) => value.trim().toLowerCase();

export function PresenceProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<PresenceState>(initialState);

  const addActivity = (title: string, detail: string) => {
    setState((current) => ({
      ...current,
      activity: [{ id: Date.now(), time: now(), title, detail }, ...current.activity].slice(0, 10)
    }));
  };

  const addToast = (toast: Omit<Toast, "id">) => {
    setState((current) => {
      if (!current.notificationsEnabled && toast.tone !== "security") {
        return current;
      }
      return {
        ...current,
        status: "notification",
        message: toast.title,
        toasts: [{ id: Date.now(), ...toast }, ...current.toasts].slice(0, 4)
      };
    });
  };

  const completeFastTask = (task: string, detail: string, delay = 850) => {
    setTimeout(() => {
      setState((current) => ({
        ...current,
        status: "idle",
        activeTask: null,
        message: "Cove"
      }));
      addActivity(task, detail);
      addToast({ tone: "complete", title: "Task completed.", detail });
    }, delay);
  };

  const actions: PresenceActions = useMemo(
    () => ({
      setPlatform: (platform) => setState((current) => ({ ...current, platform })),
      setCurrentApp: (currentApp) => {
        setState((current) => ({ ...current, currentApp }));
        addActivity(`Context changed to ${currentApp}`, "Screen context is simulated for this prototype.");
      },
      setCommandText: (commandText) => setState((current) => ({ ...current, commandText })),
      completeSetup: () => {
        setState((current) => ({
          ...current,
          setupComplete: true,
          permissionMode: current.setupDraft.permissionMode,
          presenceMode: current.setupDraft.presenceMode,
          voiceEnabled: current.setupDraft.voiceEnabled,
          launchOnStartup: current.setupDraft.launchOnStartup,
          appAccess: current.setupDraft.appAccess,
          status: current.setupDraft.voiceEnabled && current.audioDeviceConnected ? "listening" : "text",
          message:
            current.setupDraft.voiceEnabled && current.audioDeviceConnected
              ? "Cove listening..."
              : "Text mode ready."
        }));
        addActivity("Completed first install", "Security, presence, voice, startup, and app access configured.");
      },
      updateSetup: (draft) =>
        setState((current) => ({ ...current, setupDraft: { ...current.setupDraft, ...draft } })),
      toggleSetupAccess: (app) =>
        setState((current) => {
          const enabled = current.setupDraft.appAccess.includes(app);
          return {
            ...current,
            setupDraft: {
              ...current.setupDraft,
              appAccess: enabled
                ? current.setupDraft.appAccess.filter((item) => item !== app)
                : [...current.setupDraft.appAccess, app]
            }
          };
        }),
      runCommand: (raw) => {
        const command = lower(raw);
        if (!command) {
          return;
        }
        setState((current) => ({ ...current, commandText: "", status: "thinking", message: "Cove processing..." }));

        if (command.includes("earn me money")) {
          addActivity("Money request declined", "Cove cannot guarantee income or financial outcomes.");
          addToast({
            tone: "risk",
            title: "Financial boundary.",
            detail: "I cannot guarantee income or financial outcomes. I can assist with approved workflows and research."
          });
          setState((current) => ({ ...current, status: "idle", message: "Cove" }));
          return;
        }

        if (command.includes("buy ") || command.includes("sell ") || command.includes("invest now")) {
          addActivity("Trading advice blocked", "Cove provided risk language only.");
          addToast({
            tone: "risk",
            title: "Risk warning.",
            detail: "Risk appears elevated. Volatility increased. Potential downside detected."
          });
          setState((current) => ({ ...current, status: "idle", message: "Cove" }));
          return;
        }

        const agentMatch =
          agentExamples.find((agent) => command.includes(agent.toLowerCase())) ?? resolveAgentAlias(command);
        if (agentMatch) {
          actions.runAgent(agentMatch);
          return;
        }

        if (command.includes("text sudharshan")) {
          actions.runTask("Text Sudharshan");
          return;
        }

        const taskMatch = quickTasks.find((task) => command.includes(task.replace("Open ", "").toLowerCase()));
        actions.runTask(taskMatch ?? raw);
      },
      runTask: (task) => {
        const app = task.replace("Open ", "");
        setState((current) => ({
          ...current,
          status: "task",
          activeTask: task,
          activeAgent: null,
          agentStage: null,
          agentProgress: 0,
          message: `${task}...`
        }));

        if (agentExamples.includes(task)) {
          addActivity("Agent route selected", `${task} is long-running work, so Cove used agent mode.`);
          actions.runAgent(task);
          return;
        }

        if (task === "Text Sudharshan") {
          setState((current) => {
            const allowSend = () => {
              setState((next) => ({
                ...next,
                status: "task",
                permissionRequest: null,
                message: "Sending WhatsApp message...",
                activeTask: "Text Sudharshan"
              }));
              completeFastTask("Texted Sudharshan", "Sent simulated WhatsApp message: How was your day?");
            };

            if (current.permissionMode === "Autonomous") {
              setTimeout(allowSend, 500);
              return {
                ...current,
                status: "task",
                message: "Sending automatically inside approved scope."
              };
            }

            return {
              ...current,
              status: "permission",
              message: "Send message to Sudharshan?",
              permissionRequest: {
                title: "Send WhatsApp message?",
                app: "WhatsApp",
                action: "Send message to Sudharshan",
                reason: `${current.permissionMode} mode asks before sending messages.`,
                preview: "How was your day?",
                risk: "medium",
                onAllow: allowSend
              }
            };
          });
          return;
        }

        if (task === "Summarize PDF") {
          completeFastTask("Summarized PDF", "Generated a simulated 5-bullet summary.");
          return;
        }

        if (task === "Summarize lecture") {
          completeFastTask("Summarized lecture", "Generated simulated chapter notes for the lecture.");
          return;
        }

        if (task === "Summarize inbox") {
          completeFastTask("Summarized inbox", "Created a simulated priority email summary.");
          return;
        }

        if (task === "Need help debugging") {
          completeFastTask("Opened coding assistance", "Prepared simulated debugging context for VSCode.");
          return;
        }

        completeFastTask(`Opened ${app}`, `${app} launch simulated locally. No real app was opened.`);
      },
      runAgent: (agent) => {
        if (!agentExamples.includes(agent)) {
          addActivity("Agent not created", `${agent} is a fast task and does not need an agent.`);
          addToast({ tone: "complete", title: "Handled as task.", detail: "Cove did not deploy an agent for a simple command." });
          return;
        }

        setState((current) => ({
          ...current,
          status: "agent",
          activeAgent: agent,
          agentStage: "planning",
          agentProgress: 12,
          activeTask: null,
          message: `${agent} planning...`
        }));
        addActivity(`Created ${agent} Agent`, "Agent runtime is simulated and scoped to this prototype.");

        setTimeout(() => {
          setState((current) => {
            if (current.activeAgent !== agent) {
              return current;
            }
            return {
              ...current,
              status: "agent",
              activeAgent: agent,
              agentStage: "running",
              agentProgress: 48,
              activeTask: null,
              message: `${agent} running...`
            };
          });
        }, 700);

        setTimeout(() => {
          setState((current) => {
            if (current.activeAgent !== agent) {
              return current;
            }
            return {
            ...current,
            status: "agent",
            activeAgent: agent,
            agentStage: "completed",
            agentProgress: 100,
            message: `${agent} completed.`
            };
          });
          addActivity("Agent completed", `${agent} finished its simulated run.`);
          addToast({ tone: "complete", title: "Agent completed.", detail: `${agent} finished its simulated run.` });
        }, 2600);

        setTimeout(() => {
          setState((current) => {
            if (current.activeAgent !== agent) {
              return current;
            }
            return {
              ...current,
              status: "idle",
              activeAgent: null,
              agentStage: null,
              agentProgress: 0,
              message: "Cove"
            };
          });
        }, 4300);
      },
      pauseAgent: () => {
        setState((current) => {
          if (!current.activeAgent || !current.agentStage) {
            return current;
          }
          const paused = current.agentStage === "paused";
          return {
            ...current,
            agentStage: paused ? "running" : "paused",
            agentProgress: paused ? Math.max(current.agentProgress, 52) : current.agentProgress,
            message: paused ? `${current.activeAgent} running...` : `${current.activeAgent} paused.`
          };
        });
      },
      stopAgent: () => {
        setState((current) => ({
          ...current,
          status: "idle",
          activeAgent: null,
          agentStage: null,
          agentProgress: 0,
          message: "Cove"
        }));
        addActivity("Agent stopped", "Stopped the active simulated agent.");
        addToast({ tone: "permission", title: "Agent stopped.", detail: "Cove paused the running automation." });
      },
      approvePermission: () => {
        const request = state.permissionRequest;
        if (request) {
          addActivity("Permission allowed", `${request.action} in ${request.app}.`);
          request.onAllow();
        }
      },
      denyPermission: () => {
        const request = state.permissionRequest;
        setState((current) => ({
          ...current,
          permissionRequest: null,
          activeTask: null,
          agentStage: null,
          agentProgress: 0,
          status: "idle",
          message: "Cove"
        }));
        addActivity("Permission denied", request ? `${request.action} was stopped.` : "Action stopped.");
        addToast({ tone: "permission", title: "Permission denied.", detail: "Cove stopped the simulated action." });
      },
      openSettings: () => setState((current) => ({ ...current, settingsOpen: true })),
      closeSettings: () => setState((current) => ({ ...current, settingsOpen: false })),
      toggleActivity: () => setState((current) => ({ ...current, activityOpen: !current.activityOpen })),
      dismissToast: (id) =>
        setState((current) => ({ ...current, toasts: current.toasts.filter((toast) => toast.id !== id) })),
      updatePermissionMode: (permissionMode) => setState((current) => ({ ...current, permissionMode })),
      updatePresenceMode: (presenceMode) => setState((current) => ({ ...current, presenceMode })),
      toggleVoice: () =>
        setState((current) => ({
          ...current,
          voiceEnabled: !current.voiceEnabled,
          status: !current.voiceEnabled && current.audioDeviceConnected ? "listening" : "text",
          message: !current.voiceEnabled && current.audioDeviceConnected ? "Cove listening..." : "Text mode ready."
        })),
      toggleAudioDevice: () =>
        setState((current) => {
          const audioDeviceConnected = !current.audioDeviceConnected;
          const voiceReady = current.voiceEnabled && audioDeviceConnected;
          return {
            ...current,
            audioDeviceConnected,
            status: voiceReady ? "listening" : "text",
            message: voiceReady ? "Cove listening..." : "Audio absent. Text mode ready."
          };
        }),
      toggleAppAccess: (app) =>
        setState((current) => {
          const enabled = current.appAccess.includes(app);
          return {
            ...current,
            appAccess: enabled ? current.appAccess.filter((item) => item !== app) : [...current.appAccess, app]
          };
        }),
      toggleAgentAccess: () => setState((current) => ({ ...current, agentAccess: !current.agentAccess })),
      toggleMemory: () => setState((current) => ({ ...current, memoryEnabled: !current.memoryEnabled })),
      toggleNotifications: () =>
        setState((current) => ({ ...current, notificationsEnabled: !current.notificationsEnabled })),
      togglePrivacy: (key) =>
        setState((current) => {
          const nextPrivacy = { ...current.privacy, [key]: !current.privacy[key] };
          const killSwitch = key === "killSwitch" ? nextPrivacy.killSwitch : nextPrivacy.killSwitch;
          return {
            ...current,
            privacy: nextPrivacy,
            status: killSwitch ? "idle" : current.status,
            message: killSwitch ? "Cove stopped." : current.message,
            activeAgent: killSwitch ? null : current.activeAgent,
            agentStage: killSwitch ? null : current.agentStage,
            agentProgress: killSwitch ? 0 : current.agentProgress,
            activeTask: killSwitch ? null : current.activeTask
          };
        }),
      collapse: () =>
        setState((current) => ({
          ...current,
          status: "idle",
          message: "Cove",
          settingsOpen: false,
          activeAgent: null,
          agentStage: null,
          agentProgress: 0,
          activeTask: null,
          permissionRequest: null
        }))
    }),
    [state.permissionRequest]
  );

  return <PresenceContext.Provider value={{ state, actions }}>{children}</PresenceContext.Provider>;
}

export const quickTasks = [
  "Open Spotify",
  "Open YouTube",
  "Open WhatsApp",
  "Open Gmail",
  "Open Discord",
  "Open VSCode",
  "Text Sudharshan"
];

export const agentExamples = [
  "Email Agent",
  "AI News Agent",
  "Research Agent",
  "Website Builder Agent"
];

function resolveAgentAlias(command: string) {
  if (command.includes("email") || command.includes("filter 500")) return "Email Agent";
  if (command.includes("ai news") || command.includes("monitor news")) return "AI News Agent";
  if (command.includes("research") || command.includes("robotics jobs")) return "Research Agent";
  if (command.includes("website") || command.includes("build site")) return "Website Builder Agent";
  return undefined;
}

export const setupAccessOptions = appAccessOptions;

export function usePresence() {
  const context = useContext(PresenceContext);
  if (!context) {
    throw new Error("usePresence must be used inside PresenceProvider");
  }
  return context;
}

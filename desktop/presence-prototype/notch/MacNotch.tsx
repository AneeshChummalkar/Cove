import { useEffect } from "react";
import { usePresence } from "../state/presenceStore";

const statusCopy = {
  idle: "Cove",
  listening: "Cove listening...",
  text: "Text mode ready.",
  thinking: "Cove processing...",
  task: "Task running...",
  agent: "Agent running...",
  permission: "Permission required.",
  notification: "Cove notification."
};

export function MacNotch() {
  const { state, actions } = usePresence();
  const expanded = state.settingsOpen || state.status !== "idle" || state.activeAgent || state.activeTask || state.permissionRequest;
  const voiceReady = state.voiceEnabled && state.audioDeviceConnected;

  useEffect(() => {
    if (!state.settingsOpen) {
      return;
    }

    const timer = window.setTimeout(() => actions.closeSettings(), 14000);
    return () => window.clearTimeout(timer);
  }, [actions, state.settingsOpen]);

  return (
    <div className={`mac-notch ${expanded ? "expanded" : ""} state-${state.status}`}>
      <button
        className="notch-body"
        onClick={state.settingsOpen ? actions.closeSettings : actions.openSettings}
        aria-label="Cove notch"
      >
        <span className="notch-sensor" />
        <span className="notch-pulse" />
        <span className="notch-text">
          <strong>{state.message || statusCopy[state.status]}</strong>
          <small>{voiceReady ? "Mic Voice mode" : "Keyboard Text mode"}</small>
        </span>
        <span className="notch-action">{state.settingsOpen ? "Close" : "Open"}</span>
      </button>
    </div>
  );
}

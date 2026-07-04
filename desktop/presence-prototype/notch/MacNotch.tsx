import { FormEvent, useEffect } from "react";
import { usePresence } from "../state/presenceStore";

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

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    actions.runCommand(state.commandText);
  };

  const title = getNotchTitle(state.message, state.activeAgent, state.status);
  const detail = voiceReady ? `${state.presenceMode} - voice ready` : `${state.presenceMode} - text mode`;

  return (
    <div className={`mac-notch ${expanded ? "expanded" : ""} state-${state.status}`}>
      <div className="notch-body" role="group" aria-label="Cove notch">
        <button
          className="notch-summary"
          onClick={state.settingsOpen ? actions.closeSettings : actions.openSettings}
          aria-label={state.settingsOpen ? "Close Cove settings" : "Open Cove settings"}
        >
          <span className="notch-sensor" />
          <span className="notch-pulse" />
          <span className="notch-text">
            <strong>{title}</strong>
            <small>{detail}</small>
          </span>
          <span className="notch-chevron">{state.settingsOpen ? "Done" : "Cove"}</span>
        </button>

        {state.status === "text" && !state.permissionRequest ? (
          <form className="notch-input" onSubmit={submit}>
            <input
              value={state.commandText}
              onChange={(event) => actions.setCommandText(event.target.value)}
              placeholder="Ask Cove..."
              aria-label="Ask Cove"
            />
            <button type="submit">Ask</button>
          </form>
        ) : null}

        {state.permissionRequest ? (
          <div className="notch-permission">
            <span>{state.permissionRequest.app}</span>
            <strong>{state.permissionRequest.action}</strong>
            <small>{state.permissionRequest.preview}</small>
            <div>
              <button onClick={actions.denyPermission}>Deny</button>
              <button className="primary-action" onClick={actions.approvePermission}>
                Allow
              </button>
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
}

function getNotchTitle(message: string, activeAgent: string | null, status: string) {
  if (activeAgent && status === "agent") return `${activeAgent} running...`;
  if (status === "listening") return "Listening...";
  if (status === "text") return "Ask Cove...";
  if (status === "thinking") return "Thinking...";
  if (status === "task") return message || "Task running...";
  if (status === "permission") return message || "Permission required.";
  if (status === "notification") return message || "Notification";
  return "Cove";
}

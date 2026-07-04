import { ReactNode } from "react";
import {
  agentExamples,
  AppContext,
  setupAccessOptions,
  PermissionMode,
  PresenceMode,
  usePresence
} from "../state/presenceStore";

const permissionModes: PermissionMode[] = ["Safe", "Balanced", "Autonomous"];
const presenceModes: PresenceMode[] = ["Ghost", "Assistant", "Companion", "Agentic"];
const contextSamples: AppContext[] = ["PDF", "YouTube", "Gmail", "VSCode"];

export function SettingsSheet() {
  const { state, actions } = usePresence();

  if (!state.settingsOpen) {
    return null;
  }

  return (
    <div className="settings-anchor">
      <section className="settings-sheet" aria-label="Cove settings">
        <header>
          <div>
            <span>Settings</span>
            <strong>Cove presence</strong>
          </div>
          <button onClick={actions.closeSettings}>Done</button>
        </header>

        <div className="settings-scroll">
          <Section title="Security">
            <Toggle label="Private mode" checked={state.privacy.privateMode} onChange={() => actions.togglePrivacy("privateMode")} />
            <Toggle label="Screen context" checked={state.privacy.screenObservation} onChange={() => actions.togglePrivacy("screenObservation")} />
          </Section>

          <Section title="Presence">
            <div className="segmented four">
              {presenceModes.map((mode) => (
                <button
                  key={mode}
                  className={state.presenceMode === mode ? "active" : ""}
                  onClick={() => actions.updatePresenceMode(mode)}
                >
                  {mode}
                </button>
              ))}
            </div>
          </Section>

          <Section title="Permissions">
            <div className="segmented three">
              {permissionModes.map((mode) => (
                <button
                  key={mode}
                  className={state.permissionMode === mode ? "active" : ""}
                  onClick={() => actions.updatePermissionMode(mode)}
                >
                  {mode}
                </button>
              ))}
            </div>
            <button className="surface-action" onClick={() => actions.runTask("Text Sudharshan")}>
              Send message to Sudharshan?
            </button>
          </Section>

          <Section title="Voice">
            <Toggle label="Voice" checked={state.voiceEnabled} onChange={actions.toggleVoice} />
            <Toggle label="Bluetooth headset or mic" checked={state.audioDeviceConnected} onChange={actions.toggleAudioDevice} />
          </Section>

          <Section title="Apps">
            <div className="access-grid">
              {setupAccessOptions.slice(0, 8).map((app) => (
                <label key={app} className="access-chip">
                  <input type="checkbox" checked={state.appAccess.includes(app)} onChange={() => actions.toggleAppAccess(app)} />
                  <span>{app}</span>
                </label>
              ))}
            </div>
            <div className="compact-actions">
              {contextSamples.map((context) => (
                <button key={context} onClick={() => actions.setCurrentApp(context)}>
                  {context === "YouTube" ? "Lecture" : context}
                </button>
              ))}
            </div>
          </Section>

          <Section title="Privacy">
            <Toggle label="Suggestions" checked={state.privacy.suggestions} onChange={() => actions.togglePrivacy("suggestions")} />
            <Toggle label="Pause presence" checked={state.privacy.paused} onChange={() => actions.togglePrivacy("paused")} />
          </Section>

          <Section title="Memory">
            <Toggle label="Remember preferences" checked={state.memoryEnabled} onChange={actions.toggleMemory} />
          </Section>

          <Section title="Notifications">
            <Toggle label="Top-right notifications" checked={state.notificationsEnabled} onChange={actions.toggleNotifications} />
          </Section>

          <Section title="Agents">
            <Toggle label="Agent runtime" checked={state.agentAccess} onChange={actions.toggleAgentAccess} />
            <div className="compact-actions">
              {agentExamples.map((agent) => (
                <button key={agent} onClick={() => actions.runAgent(agent)}>
                  {agent.replace(" Agent", "")}
                </button>
              ))}
            </div>
          </Section>

          <Section title="Kill Switch">
            <Toggle label="Stop Cove immediately" checked={state.privacy.killSwitch} onChange={() => actions.togglePrivacy("killSwitch")} danger />
          </Section>
        </div>
      </section>
    </div>
  );
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="settings-section">
      <h3>{title}</h3>
      {children}
    </section>
  );
}

function Toggle({
  label,
  checked,
  onChange,
  danger = false
}: {
  label: string;
  checked: boolean;
  onChange: () => void;
  danger?: boolean;
}) {
  return (
    <label className={danger ? "switch-row danger" : "switch-row"}>
      <span>{label}</span>
      <input type="checkbox" checked={checked} onChange={onChange} />
    </label>
  );
}

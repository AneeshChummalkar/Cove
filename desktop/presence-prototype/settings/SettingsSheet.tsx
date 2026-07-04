import { setupAccessOptions, PermissionMode, PresenceMode, usePresence } from "../state/presenceStore";

const permissionModes: PermissionMode[] = ["Safe", "Balanced", "Autonomous"];
const presenceModes: PresenceMode[] = ["Ghost", "Assistant", "Companion", "Agentic"];

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
            <strong>Cove controls</strong>
          </div>
          <button onClick={actions.closeSettings}>Done</button>
        </header>

        <div className="settings-scroll">
          <section className="settings-section">
            <h3>Presence Mode</h3>
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
          </section>

          <section className="settings-section">
            <h3>Permission Mode</h3>
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
          </section>

          <section className="settings-section two-col">
            <Toggle label="Voice" checked={state.voiceEnabled} onChange={actions.toggleVoice} />
            <Toggle label="Trusted audio device" checked={state.audioDeviceConnected} onChange={actions.toggleAudioDevice} />
            <Toggle label="Agent Access" checked={state.agentAccess} onChange={actions.toggleAgentAccess} />
            <Toggle label="Memory" checked={state.memoryEnabled} onChange={actions.toggleMemory} />
            <Toggle label="Notifications" checked={state.notificationsEnabled} onChange={actions.toggleNotifications} />
            <Toggle label="Kill Switch" checked={state.privacy.killSwitch} onChange={() => actions.togglePrivacy("killSwitch")} danger />
          </section>

          <section className="settings-section">
            <h3>App Access</h3>
            <div className="access-grid compact">
              {setupAccessOptions.map((app) => (
                <label key={app} className="access-chip">
                  <input type="checkbox" checked={state.appAccess.includes(app)} onChange={() => actions.toggleAppAccess(app)} />
                  <span>{app}</span>
                </label>
              ))}
            </div>
          </section>

          <section className="settings-section">
            <h3>Security</h3>
            <div className="trust-matrix">
              <div>
                <span>What Cove sees</span>
                <strong>{state.privacy.screenObservation ? `Simulated ${state.currentApp}` : "Nothing"}</strong>
              </div>
              <div>
                <span>What Cove remembers</span>
                <strong>{state.memoryEnabled ? state.remembers.join(", ") : "Memory disabled"}</strong>
              </div>
              <div>
                <span>What Cove controls</span>
                <strong>{state.privacy.killSwitch ? "Nothing" : state.controls.join(", ")}</strong>
              </div>
              <div>
                <span>Why Cove acted</span>
                <strong>Based on explicit simulated command or selected desktop context.</strong>
              </div>
              <div>
                <span>How to stop Cove</span>
                <strong>Pause Cove, disable suggestions, private mode, or kill switch.</strong>
              </div>
              <div>
                <span>Trusted Devices</span>
                <strong>{state.trustedDevices.join(", ")}</strong>
              </div>
            </div>
          </section>
        </div>
      </section>
    </div>
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

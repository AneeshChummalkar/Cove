import { usePresence } from "../state/presenceStore";

export function TrustStrip() {
  const { state, actions } = usePresence();
  const sees = state.privacy.screenObservation ? `Simulated ${state.currentApp} context` : "Nothing";
  const remembers = state.memoryEnabled ? `${state.remembers.length} local memories` : "Memory disabled";
  const controls = state.privacy.killSwitch ? "Nothing" : `${state.controls.length} simulated apps`;
  const doing = state.activeAgent ?? state.activeTask ?? "Waiting";

  return (
    <aside className="trust-strip" aria-label="Trust details">
      <div>
        <span>Sees</span>
        <strong>{sees}</strong>
      </div>
      <div>
        <span>Remembers</span>
        <strong>{remembers}</strong>
      </div>
      <div>
        <span>Controls</span>
        <strong>{controls}</strong>
      </div>
      <div>
        <span>Doing now</span>
        <strong>{doing}</strong>
      </div>
      <button onClick={actions.toggleActivity}>Activity</button>
      <button onClick={actions.openSettings}>Settings</button>
    </aside>
  );
}

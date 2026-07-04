import { usePresence } from "../state/presenceStore";

export function AgentMode() {
  const { state, actions } = usePresence();

  if (!state.activeAgent || !state.agentStage) {
    return null;
  }

  return (
    <section className="agent-shelf" aria-label="Agent mode simulations">
      <div>
        <span>{state.agentStage}</span>
        <strong>{state.activeAgent}</strong>
      </div>
      <div className="agent-actions">
        <button onClick={actions.pauseAgent}>{state.agentStage === "paused" ? "Resume" : "Pause"}</button>
        <button onClick={actions.collapse}>Dismiss</button>
      </div>
    </section>
  );
}

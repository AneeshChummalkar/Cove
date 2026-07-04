import { usePresence } from "../state/presenceStore";

export function AgentMode() {
  const { state, actions } = usePresence();

  if (!state.activeAgent || !state.agentStage) {
    return null;
  }

  return (
    <section className="agent-popup" aria-label="Active Cove agent">
      <div>
        <span>{state.agentStage}</span>
        <strong>{state.activeAgent}</strong>
        <small>{agentTask(state.activeAgent)}</small>
      </div>
      <div className="agent-progress" aria-label={`${state.agentProgress}% complete`}>
        <span style={{ width: `${state.agentProgress}%` }} />
      </div>
      <div className="agent-actions">
        <button onClick={actions.pauseAgent}>{state.agentStage === "paused" ? "Resume" : "Pause"}</button>
        <button onClick={actions.stopAgent}>Stop</button>
      </div>
    </section>
  );
}

function agentTask(agent: string) {
  if (agent === "Email Agent") return "Filtering priority messages";
  if (agent === "AI News Agent") return "Watching AI sources";
  if (agent === "Research Agent") return "Collecting citations";
  if (agent === "Website Builder Agent") return "Building page draft";
  return "Running scoped task";
}

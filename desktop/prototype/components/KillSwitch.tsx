import { useCovePrototype } from "../state/prototypeStore";

export function KillSwitch() {
  const { state, dispatch } = useCovePrototype();

  return (
    <section className={`kill-switch ${state.killSwitch ? "engaged" : ""}`}>
      <div>
        <strong>{state.killSwitch ? "Cove paused." : "Kill Switch"}</strong>
        <span>{state.killSwitch ? "Tasks, agents, notifications, and observations stopped." : "Stop all simulated Cove activity."}</span>
      </div>
      {state.killSwitch ? (
        <button className="secondary" onClick={() => dispatch({ type: "RESET_SIMULATION" })}>
          Reset
        </button>
      ) : (
        <button className="danger" onClick={() => dispatch({ type: "KILL_SWITCH" })}>
          Stop
        </button>
      )}
    </section>
  );
}

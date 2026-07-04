import { PresenceMode, PermissionMode, useCovePrototype } from "../state/prototypeStore";

const presenceOrder: PresenceMode[] = ["GHOST", "ASSISTANT", "COMPANION", "AGENTIC"];
const permissionOrder: PermissionMode[] = ["SAFE", "BALANCED", "AUTONOMOUS"];

export function LeftSidebar() {
  const { state, data, dispatch } = useCovePrototype();

  return (
    <aside className="left-sidebar surface">
      <section className="mode-block">
        <div className="section-heading">
          <span>Presence Mode</span>
          <small>{data.presenceModes[state.presenceMode].popupFrequency}</small>
        </div>
        <div className="segmented vertical">
          {presenceOrder.map((mode) => (
            <button
              key={mode}
              className={state.presenceMode === mode ? "selected" : ""}
              onClick={() => dispatch({ type: "SET_PRESENCE", mode })}
            >
              <span>{data.presenceModes[mode].label}</span>
              <small>{data.presenceModes[mode].agentVisibility}</small>
            </button>
          ))}
        </div>
      </section>

      <section className="mode-block">
        <div className="section-heading">
          <span>Permission Mode</span>
          <small>{data.permissionModes[state.permissionMode].label}</small>
        </div>
        <div className="segmented vertical permission-buttons">
          {permissionOrder.map((mode) => (
            <button
              key={mode}
              className={state.permissionMode === mode ? "selected" : ""}
              onClick={() => dispatch({ type: "SET_PERMISSION", mode })}
            >
              <span>{data.permissionModes[mode].label}</span>
              <small>{data.permissionModes[mode].description}</small>
            </button>
          ))}
        </div>
      </section>

      <section className="mode-block">
        <div className="section-heading">
          <span>Agent List</span>
          <small>{state.agents.filter((agent) => agent.status === "running" || agent.status === "planning").length} active</small>
        </div>
        <div className="list-stack">
          {state.agents.map((agent) => (
            <button
              key={agent.id}
              className={`agent-row status-${agent.status} ${state.activeAgentId === agent.id ? "focused" : ""}`}
              onClick={() => dispatch({ type: "START_AGENT", id: agent.id })}
            >
              <span>
                <strong>{agent.name}</strong>
                <small>{agent.goal}</small>
              </span>
              <b>{agent.progress}%</b>
            </button>
          ))}
        </div>
      </section>

      <section className="mode-block task-history">
        <div className="section-heading">
          <span>Task History</span>
          <small>Task Mode</small>
        </div>
        <div className="list-stack">
          {state.tasks.map((task) => (
            <button
              key={task.id}
              className={`task-row status-${task.status} ${state.activeTaskId === task.id ? "focused" : ""}`}
              onClick={() => dispatch({ type: "START_TASK", id: task.id })}
            >
              <span>
                <strong>{task.title}</strong>
                <small>{task.target}</small>
              </span>
              <b>{task.status}</b>
            </button>
          ))}
        </div>
      </section>
    </aside>
  );
}

import { AppContext, agentExamples, quickTasks, usePresence } from "../state/presenceStore";

const contexts: AppContext[] = ["PDF", "YouTube", "Gmail", "VSCode", "WhatsApp", "Desktop"];

export function SimulationRail() {
  const { state, actions } = usePresence();

  return (
    <section className="simulation-rail" aria-label="Prototype simulation controls">
      <div className="rail-row">
        <button className={state.platform === "mac" ? "active" : ""} onClick={() => actions.setPlatform("mac")}>
          mac
        </button>
        <button className={state.platform === "windows" ? "active" : ""} onClick={() => actions.setPlatform("windows")}>
          win
        </button>
        <button onClick={actions.toggleAudioDevice}>
          {state.audioDeviceConnected ? "audio on" : "audio off"}
        </button>
      </div>
      <div className="rail-row">
        {contexts.map((context) => (
          <button
            key={context}
            className={state.currentApp === context ? "active" : ""}
            onClick={() => actions.setCurrentApp(context)}
          >
            {context}
          </button>
        ))}
      </div>
      <div className="rail-row">
        {quickTasks.slice(0, 4).map((task) => (
          <button key={task} onClick={() => actions.runTask(task)}>
            {task.replace("Open ", "")}
          </button>
        ))}
        <button onClick={() => actions.runTask("Text Sudharshan")}>Text</button>
      </div>
      <div className="rail-row">
        {agentExamples.map((agent) => (
          <button key={agent} onClick={() => actions.runAgent(agent)}>
            {agent.replace(" Agent", "")}
          </button>
        ))}
      </div>
    </section>
  );
}

import { CursorRuntime } from "./CursorRuntime";
import { MacNotch } from "./MacNotch";
import { MemoryPreview } from "./MemoryPreview";
import { Notifications } from "./Notifications";
import { StatusMeter } from "./StatusMeter";
import { useCovePrototype } from "../state/prototypeStore";

export function CenterWorkspace() {
  const { state, dispatch } = useCovePrototype();
  const activeTask = state.tasks.find((task) => task.id === state.activeTaskId) ?? state.tasks[0];
  const activeAgent = state.agents.find((agent) => agent.id === state.activeAgentId) ?? state.agents[0];
  const currentStage = activeAgent.stages[activeAgent.stageIndex] ?? activeAgent.stages[0];

  return (
    <section className="center-workspace">
      <MacNotch />

      <div className="current-grid">
        <article className={`focus-panel status-${activeTask.status}`}>
          <div className="section-heading">
            <span>Current Task</span>
            <small>{activeTask.status}</small>
          </div>
          <h2>{activeTask.title}</h2>
          <p>{activeTask.description}</p>
          <StatusMeter value={activeTask.progress} label={`${activeTask.title} progress`} />
          <div className="action-row">
            <button onClick={() => dispatch({ type: "START_TASK", id: activeTask.id })}>Run Task</button>
            <button className="secondary" onClick={() => dispatch({ type: "START_TASK", id: "text-sudharshan" })}>
              Send Message
            </button>
          </div>
        </article>

        <article className={`focus-panel status-${activeAgent.status}`}>
          <div className="section-heading">
            <span>Current Agent</span>
            <small>{activeAgent.status}</small>
          </div>
          <h2>{activeAgent.name}</h2>
          <p>{activeAgent.goal}</p>
          <StatusMeter value={activeAgent.progress} label={`${activeAgent.name} progress`} />
          <div className="agent-stage">
            <span>{currentStage}</span>
            <small>{activeAgent.memoryNamespace}</small>
          </div>
          <div className="action-row">
            <button onClick={() => dispatch({ type: "START_AGENT", id: activeAgent.id })}>Run Agent</button>
            <button className="secondary" onClick={() => dispatch({ type: "START_AGENT", id: "monitor-ai-news" })}>
              News Agent
            </button>
          </div>
        </article>
      </div>

      <Notifications />
      <CursorRuntime />
      <MemoryPreview />
    </section>
  );
}

import { FormEvent } from "react";
import { quickTasks, usePresence } from "../state/presenceStore";

export function TaskCommandPalette() {
  const { state, actions } = usePresence();

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    actions.runCommand(state.commandText);
  };

  return (
    <form className="command-strip" onSubmit={submit}>
      <div className="input-wrap">
        <span>{state.voiceEnabled && state.audioDeviceConnected ? "Voice" : "Text"}</span>
        <input
          value={state.commandText}
          onChange={(event) => actions.setCommandText(event.target.value)}
          placeholder="Ask Cove..."
          aria-label="Ask Cove"
        />
      </div>
      <button type="submit">Run</button>
      <div className="quick-task-row" aria-label="Fast tasks">
        {quickTasks.map((task) => (
          <button key={task} type="button" onClick={() => actions.runTask(task)}>
            {task}
          </button>
        ))}
      </div>
    </form>
  );
}

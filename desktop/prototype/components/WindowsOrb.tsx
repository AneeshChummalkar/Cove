import { PointerEvent, useMemo, useRef } from "react";
import { RuntimeStatus, useCovePrototype } from "../state/prototypeStore";

const orbSymbols: Record<RuntimeStatus, string> = {
  idle: "○",
  listening: "◉",
  thinking: "◌",
  task: "◉",
  agent: "✦",
  permission: "⚠",
  paused: "○"
};

const orbLabels: Record<RuntimeStatus, string> = {
  idle: "Idle",
  listening: "Listening",
  thinking: "Thinking",
  task: "Task Running",
  agent: "Agent Running",
  permission: "Permission Required",
  paused: "Paused"
};

export function WindowsOrb() {
  const { state, dispatch } = useCovePrototype();
  const dragOffset = useRef({ x: 0, y: 0 });
  const activeAgent = state.agents.find((agent) => agent.status === "running" || agent.status === "planning");

  const activeText = useMemo(() => {
    if (state.runtimeStatus === "agent" && activeAgent) {
      return activeAgent.name;
    }
    if (state.runtimeStatus === "task") {
      const task = state.tasks.find((item) => item.status === "running" || item.status === "planning");
      return task?.title ?? "Task Mode";
    }
    return orbLabels[state.runtimeStatus];
  }, [activeAgent, state.agents, state.runtimeStatus, state.tasks]);

  const onPointerDown = (event: PointerEvent<HTMLDivElement>) => {
    dragOffset.current = {
      x: event.clientX - state.orbPosition.x,
      y: event.clientY - state.orbPosition.y
    };
    event.currentTarget.setPointerCapture(event.pointerId);
  };

  const onPointerMove = (event: PointerEvent<HTMLDivElement>) => {
    if (!event.currentTarget.hasPointerCapture(event.pointerId)) {
      return;
    }
    dispatch({
      type: "SET_ORB_POSITION",
      position: {
        x: Math.max(20, Math.min(window.innerWidth - 260, event.clientX - dragOffset.current.x)),
        y: Math.max(70, Math.min(window.innerHeight - 140, event.clientY - dragOffset.current.y))
      }
    });
  };

  return (
    <div
      className={`windows-orb orb-${state.runtimeStatus} ${state.orbExpanded ? "expanded" : "collapsed"}`}
      style={{ left: state.orbPosition.x, top: state.orbPosition.y }}
      onPointerDown={onPointerDown}
      onPointerMove={onPointerMove}
    >
      <button className="orb-core" onClick={() => dispatch({ type: "TOGGLE_ORB" })} aria-label="Toggle floating orb">
        <span>{orbSymbols[state.runtimeStatus]}</span>
      </button>
      <div className="orb-body">
        <strong>{activeText}</strong>
        <small>{orbLabels[state.runtimeStatus]}</small>
        <div className="orb-actions">
          <button onClick={() => dispatch({ type: "SET_PRESENCE", mode: "GHOST" })}>Quiet</button>
          <button onClick={() => dispatch({ type: "KILL_SWITCH" })}>Stop</button>
        </div>
      </div>
    </div>
  );
}

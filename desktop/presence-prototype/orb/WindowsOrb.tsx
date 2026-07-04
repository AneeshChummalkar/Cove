import { PointerEvent, useState } from "react";
import { usePresence } from "../state/presenceStore";

const glyphs = {
  idle: "○",
  listening: "◉",
  text: "○",
  thinking: "◌",
  task: "◌",
  agent: "✦",
  permission: "⚠",
  notification: "◌"
};

export function WindowsOrb() {
  const { state, actions } = usePresence();
  const [position, setPosition] = useState({ x: 32, y: 96 });
  const [dragging, setDragging] = useState(false);
  const [collapsed, setCollapsed] = useState(false);

  const onPointerMove = (event: PointerEvent<HTMLDivElement>) => {
    if (!dragging) {
      return;
    }
    setPosition({
      x: Math.max(16, Math.min(window.innerWidth - 120, event.clientX - 24)),
      y: Math.max(56, Math.min(window.innerHeight - 120, event.clientY - 24))
    });
  };

  return (
    <div
      className={`windows-orb ${collapsed ? "collapsed" : ""} state-${state.status}`}
      style={{ left: position.x, top: position.y }}
      onPointerMove={onPointerMove}
      onPointerUp={() => setDragging(false)}
      onPointerLeave={() => setDragging(false)}
    >
      <button
        className="orb-core"
        onPointerDown={() => setDragging(true)}
        onDoubleClick={() => setCollapsed((value) => !value)}
        onClick={() => (collapsed ? setCollapsed(false) : actions.openSettings())}
        aria-label="Cove orb"
      >
        <span>{glyphs[state.status]}</span>
      </button>
      {!collapsed && (
        <div className="orb-card">
          <strong>{state.message}</strong>
          <small>{state.activeAgent ?? state.activeTask ?? "Quiet desktop presence"}</small>
          <div>
            <button onClick={actions.toggleActivity}>Activity</button>
            <button onClick={() => setCollapsed(true)}>Hide</button>
          </div>
        </div>
      )}
    </div>
  );
}

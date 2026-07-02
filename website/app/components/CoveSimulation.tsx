"use client";

import { useEffect, useMemo, useState } from "react";
import type { CSSProperties } from "react";

const interactions = [
  {
    mode: "Immediate task",
    runtimeState: "LISTENING",
    speaker: "User",
    command: "Hey Cove, text Sam.",
    status: "Awaiting approval",
    activity: "Message draft ready",
    log: [
      "Understanding request",
      "Identifying Sam",
      "Drafting message",
      "Awaiting approval",
    ],
    accent: "blue",
  },
  {
    mode: "Mail summary",
    runtimeState: "THINKING",
    speaker: "User",
    command: "Hey Cove, summarize Gmail.",
    status: "Complete",
    activity: "Summary prepared on desktop",
    log: ["Connecting Gmail", "Reading messages", "Building summary", "Complete"],
    accent: "amber",
  },
  {
    mode: "Agent request",
    runtimeState: "ACTIVE",
    speaker: "User",
    command: "Hey Cove, monitor AI news.",
    status: "Agent Mode required",
    activity: "This requires Agent Mode",
    log: ["Checking scope", "Preparing agent", "Waiting for approval"],
    accent: "rose",
  },
  {
    mode: "Agent deployment",
    runtimeState: "AGENT MODE",
    speaker: "Cove",
    command: "Agent deployed.",
    status: "Runtime active",
    activity: "AI news monitor running",
    log: ["Agent deployed", "Memory initialized", "Runtime active"],
    accent: "green",
  },
];

const particles = Array.from({ length: 42 }, (_, index) => index);

export function CoveSimulation() {
  const [activeIndex, setActiveIndex] = useState(0);
  const [typed, setTyped] = useState("");
  const [pointer, setPointer] = useState({ x: 0, y: 0 });

  const active = interactions[activeIndex % interactions.length];

  useEffect(() => {
    const cycle = window.setInterval(() => {
      setTyped("");
      setActiveIndex((index) => (index + 1) % interactions.length);
    }, 5200);

    return () => window.clearInterval(cycle);
  }, []);

  useEffect(() => {
    let letter = 0;

    const writer = window.setInterval(() => {
      letter += 1;
      setTyped(active.command.slice(0, letter));

      if (letter >= active.command.length) {
        window.clearInterval(writer);
      }
    }, 34);

    return () => window.clearInterval(writer);
  }, [active.command]);

  const parallax = useMemo(
    () => ({
      "--tilt-x": `${pointer.y * -5}deg`,
      "--tilt-y": `${pointer.x * 7}deg`,
      "--shift-x": `${pointer.x * 18}px`,
      "--shift-y": `${pointer.y * 14}px`,
    }),
    [pointer],
  );

  return (
    <div
      className={`cove-simulation accent-${active.accent}`}
      style={parallax as CSSProperties}
      onPointerMove={(event) => {
        const bounds = event.currentTarget.getBoundingClientRect();
        setPointer({
          x: (event.clientX - bounds.left) / bounds.width - 0.5,
          y: (event.clientY - bounds.top) / bounds.height - 0.5,
        });
      }}
      onPointerLeave={() => setPointer({ x: 0, y: 0 })}
      aria-label="Animated Cove runtime simulation"
    >
      <div className="simulation-ambient" />
      <div className="particle-field" aria-hidden="true">
        {particles.map((particle) => (
          <span key={particle} style={{ "--i": particle } as CSSProperties} />
        ))}
      </div>

      <div className="simulation-orbit orbit-one" aria-hidden="true" />
      <div className="simulation-orbit orbit-two" aria-hidden="true" />
      <div className="simulation-orbit orbit-three" aria-hidden="true" />

      <div className="cove-core" aria-hidden="true">
        <div className="core-glow" />
        <div className="core-mark">Cove</div>
        <div className="core-status">
          <span />
          Alive
        </div>
      </div>

      <div className="simulation-glass live-simulation-panel">
        <div className="glass-header">
          <span className="status-light" />
          <span>{active.mode}</span>
        </div>
        <p className="speaker-line">{active.speaker}</p>
        <p className="type-line">
          {typed}
          <span className="caret" />
        </p>
        <div className="live-checklist">
          {active.log.map((item) => (
            <div className="log-line" key={item}>
              <span />
              {item}
            </div>
          ))}
        </div>
      </div>

      <div className="simulation-glass activity-glass">
        <div className="status-row">
          <span className="pulse-dot" />
          <strong>{active.status}</strong>
        </div>
        <p>{active.activity}</p>
      </div>

      <div className="simulation-glass permission-glass">
        <span>Permission</span>
        <strong>Ask important actions</strong>
      </div>
    </div>
  );
}

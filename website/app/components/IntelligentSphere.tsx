"use client";

import { useMemo, useState } from "react";
import type { CSSProperties } from "react";

type IntelligentSphereProps = {
  centerTitle: string;
  centerSubtitle: string;
  className?: string;
  labels?: string[];
  particleCount?: number;
};

export function IntelligentSphere({
  centerTitle,
  centerSubtitle,
  className = "",
  labels = [],
  particleCount = 3,
}: IntelligentSphereProps) {
  const [pointer, setPointer] = useState({ x: 0, y: 0 });
  const particles = Array.from({ length: particleCount }, (_, index) => index);

  const style = useMemo(
    () => ({
      "--orb-tilt-x": `${pointer.y * -7.5}deg`,
      "--orb-tilt-y": `${pointer.x * 9.5}deg`,
      "--orb-shift-x": `${pointer.x * 15}px`,
      "--orb-shift-y": `${pointer.y * 11.5}px`,
    }),
    [pointer],
  );

  return (
    <div
      className={`intelligence-sphere-wrap ${className}`}
      style={style as CSSProperties}
      onPointerMove={(event) => {
        const bounds = event.currentTarget.getBoundingClientRect();
        setPointer({
          x: (event.clientX - bounds.left) / bounds.width - 0.5,
          y: (event.clientY - bounds.top) / bounds.height - 0.5,
        });
      }}
      onPointerLeave={() => setPointer({ x: 0, y: 0 })}
      aria-hidden="true"
    >
      <div className="intelligence-particles">
        {particles.map((particle) => (
          <span key={particle} style={{ "--particle-index": particle } as CSSProperties} />
        ))}
      </div>
      <div className="intelligence-sphere">
        <div className="intelligence-core">
          <strong>{centerTitle}</strong>
          <span>{centerSubtitle}</span>
        </div>
        <div className="intelligence-orbit orbit-a" />
        <div className="intelligence-orbit orbit-b" />
        <div className="intelligence-orbit orbit-c" />
        {labels.map((label, index) => (
          <span
            className="intelligence-label"
            key={label}
            style={{ "--label-index": index, "--label-count": labels.length } as CSSProperties}
          >
            {label}
          </span>
        ))}
      </div>
    </div>
  );
}


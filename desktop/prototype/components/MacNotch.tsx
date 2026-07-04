import { RuntimeStatus, useCovePrototype } from "../state/prototypeStore";

const notchCopy: Record<RuntimeStatus, { label: string; detail: string }> = {
  idle: { label: "Cove ready", detail: "Idle" },
  listening: { label: "Cove listening...", detail: "Command capture" },
  thinking: { label: "Cove processing...", detail: "Planning" },
  task: { label: "Task running", detail: "Task Mode" },
  agent: { label: "Agent running", detail: "Agent Mode" },
  permission: { label: "Permission required.", detail: "Approval needed" },
  paused: { label: "Cove paused.", detail: "Kill switch" }
};

export function MacNotch() {
  const { state } = useCovePrototype();
  const copy = notchCopy[state.runtimeStatus];

  return (
    <div className={`mac-notch notch-${state.runtimeStatus}`} aria-label="Fake macOS notch">
      <span className="notch-dot" />
      <strong>{copy.label}</strong>
      <small>{copy.detail}</small>
    </div>
  );
}

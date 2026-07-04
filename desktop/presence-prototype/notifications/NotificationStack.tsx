import { usePresence } from "../state/presenceStore";

export function NotificationStack() {
  const { state, actions } = usePresence();

  return (
    <div className="notification-stack" aria-live="polite">
      {state.toasts.map((toast) => (
        <button key={toast.id} className={`notification-card tone-${toast.tone}`} onClick={() => actions.dismissToast(toast.id)}>
          <span>{label(toast.tone)}</span>
          <strong>{toast.title}</strong>
          <small>{toast.detail}</small>
        </button>
      ))}
    </div>
  );
}

function label(tone: string) {
  if (tone === "permission") return "Permission required";
  if (tone === "risk") return "Risk warning";
  if (tone === "security") return "Security alert";
  return "Task completed";
}

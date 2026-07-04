import { useCovePrototype } from "../state/prototypeStore";

export function Notifications() {
  const { state, dispatch } = useCovePrototype();

  return (
    <section className="workspace-section">
      <div className="section-heading">
        <span>Notifications</span>
        <small>{state.killSwitch ? "stopped" : `${state.notifications.length} live`}</small>
      </div>
      <div className="notification-stack">
        {state.notifications.map((notice) => (
          <article key={notice.id} className={`notification tone-${notice.tone}`}>
            <span>
              <strong>{notice.title}</strong>
              <small>{notice.body}</small>
            </span>
            <button aria-label={`Dismiss ${notice.title}`} onClick={() => dispatch({ type: "DISMISS_NOTIFICATION", id: notice.id })}>
              x
            </button>
          </article>
        ))}
      </div>
    </section>
  );
}

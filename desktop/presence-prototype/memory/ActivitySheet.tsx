import { usePresence } from "../state/presenceStore";

export function ActivitySheet() {
  const { state, actions } = usePresence();

  if (!state.activityOpen) {
    return null;
  }

  return (
    <section className="activity-sheet" aria-label="Recent Cove actions">
      <header>
        <div>
          <span>Activity</span>
          <strong>Recent actions</strong>
        </div>
        <button onClick={actions.toggleActivity}>Close</button>
      </header>
      <div className="activity-list">
        {state.activity.map((item) => (
          <article key={item.id}>
            <time>{item.time}</time>
            <div>
              <strong>{item.title}</strong>
              <p>{item.detail}</p>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}

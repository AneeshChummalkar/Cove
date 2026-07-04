import { useCovePrototype } from "../state/prototypeStore";

export function ActivityLog() {
  const { state } = useCovePrototype();

  return (
    <section className="right-section activity-log">
      <div className="section-heading">
        <span>Activity Log</span>
        <small>{state.activityLog.length} events</small>
      </div>
      <div className="timeline">
        {state.activityLog.map((event, index) => (
          <article key={`${event.time}-${event.title}-${index}`} className="timeline-event">
            <time>{event.time}</time>
            <strong>{event.title}</strong>
            <p>{event.detail}</p>
            <dl>
              <div>
                <dt>Why</dt>
                <dd>{event.why}</dd>
              </div>
              <div>
                <dt>Permission</dt>
                <dd>{event.permission}</dd>
              </div>
              <div>
                <dt>Memory</dt>
                <dd>{event.memory}</dd>
              </div>
            </dl>
          </article>
        ))}
      </div>
    </section>
  );
}

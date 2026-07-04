import { useCovePrototype } from "../state/prototypeStore";

export function TrustDashboard() {
  const { state, data } = useCovePrototype();

  return (
    <section className="right-section trust-dashboard">
      <div className="section-heading">
        <span>Trust Dashboard</span>
        <small>{state.killSwitch ? "paused" : state.permissionMode}</small>
      </div>
      <div className="trust-grid">
        {Object.entries(data.trustDashboard).map(([title, items]) => (
          <article key={title} className="trust-row">
            <strong>{title}</strong>
            <ul>
              {items.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </article>
        ))}
      </div>
    </section>
  );
}

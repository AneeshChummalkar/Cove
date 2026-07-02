import { SecurityOrb } from "../components/SecurityOrb";

export default function SecurityPage() {
  const controls = [
    {
      title: "Voice verification",
      body: "Cove can use enrolled voice identity to raise confidence before sensitive actions.",
    },
    {
      title: "Face recognition",
      body: "Optional presence checks help confirm the person at the computer is allowed to approve work.",
    },
    {
      title: "Trusted devices",
      body: "Only verified computers can run the runtime, sync memory, or host background agents.",
    },
    {
      title: "Permission modes",
      body: "Choose ask every action, ask important actions only, or scoped autonomy.",
    },
    {
      title: "Audit logs",
      body: "Every meaningful action records who asked, what Cove did, and which permission allowed it.",
    },
    {
      title: "Emergency kill switch",
      body: "Pause voice, agents, tool access, sync, and new permission grants immediately.",
    },
  ];

  return (
    <div className="page">
      <header className="page-header security-hero">
        <SecurityOrb />
        <div className="security-copy">
          <p className="eyebrow">Security</p>
          <h1>Powerful AI under human control.</h1>
          <p className="lead">
            Cove is designed around consent, identity, device trust, and visible
            action. The runtime can become more capable because every meaningful
            capability has a boundary.
          </p>
        </div>
      </header>
      <section className="content security-grid">
        {controls.map((control, index) => (
          <article className="security-control" key={control.title}>
            <span>{String(index + 1).padStart(2, "0")}</span>
            <h3>{control.title}</h3>
            <p>{control.body}</p>
          </article>
        ))}
      </section>
    </div>
  );
}

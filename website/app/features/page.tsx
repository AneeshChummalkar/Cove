import Link from "next/link";
import { FeaturesSphere } from "../components/FeaturesSphere";

const features = [
  {
    title: "Voice-first runtime",
    body: "Speak naturally and Cove turns intent into desktop actions with permission-aware context.",
  },
  {
    title: "Task mode",
    body: "Run bounded commands like opening apps, replying to messages, and handling quick computer tasks.",
  },
  {
    title: "Agent mode",
    body: "Create persistent agents for ongoing goals like tracking news, managing Gmail, or planning trips.",
  },
  {
    title: "Local memory",
    body: "Keep preferences, contacts, workflows, and agent state inspectable, editable, and controlled by the user.",
  },
  {
    title: "Background execution",
    body: "Let trusted agents continue working while status, audit logs, and stop controls stay visible.",
  },
  {
    title: "Advanced permissions",
    body: "Choose ask every action, ask important actions only, or scoped autonomy for trusted work.",
  },
];

export default function FeaturesPage() {
  return (
    <div className="page">
      <header className="page-header centered-header features-hero">
        <FeaturesSphere />
        <div className="features-copy">
          <p className="eyebrow">Features</p>
          <h1>Understand Cove in one minute.</h1>
          <p className="lead">
            Cove is a desktop runtime for voice commands, immediate tasks, and
            persistent agents that work with visible permissions.
          </p>
          <div className="actions centered-actions">
            <Link href="/download" className="button primary">
              <span className="icon download" aria-hidden="true" />
              Download Cove
            </Link>
            <Link href="/pricing" className="button secondary">
              View pricing
            </Link>
          </div>
        </div>
      </header>
      <section className="content feature-grid">
        {features.map((feature) => (
          <article className="feature-card" key={feature.title}>
            <h3>{feature.title}</h3>
            <p>{feature.body}</p>
          </article>
        ))}
      </section>
    </div>
  );
}

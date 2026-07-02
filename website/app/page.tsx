import Link from "next/link";
import { CoveSimulation } from "./components/CoveSimulation";

export default function Home() {
  return (
    <div className="page">
      <section className="hero">
        <div className="hero-copy">
          <p className="eyebrow">Desktop-first personal AI runtime</p>
          <h1>Cove</h1>
          <p className="lead">
            A private, voice-first AI runtime for your computer. Cove runs on
            Windows and macOS, handles immediate tasks, and hosts persistent
            agents with clear permissions.
          </p>
          <div className="actions">
            <Link href="/download" className="button primary">
              <span className="icon download" aria-hidden="true" />
              Download Cove
            </Link>
            <Link href="/security" className="button secondary">
              <span className="icon shield" aria-hidden="true" />
              Security settings
            </Link>
          </div>
          <div className="hero-signals" aria-label="Cove capabilities">
            <span>Voice-first</span>
            <span>Permissioned</span>
            <span>Agent-ready</span>
          </div>
        </div>
        <CoveSimulation />
      </section>
    </div>
  );
}

import Link from "next/link";
import { PricingCards } from "../components/PricingCards";
import { PricingSphere } from "../components/PricingSphere";

export default function PricingPage() {
  return (
    <div className="page">
      <header className="page-header centered-header pricing-hero">
        <PricingSphere />
        <div className="pricing-hero-copy">
          <p className="eyebrow">Pricing</p>
          <h1>Choose how Cove works with you.</h1>
          <p className="lead">
            Start free. Upgrade when you need persistent agents.
          </p>
        </div>
      </header>
      <section className="content pricing-content">
        <PricingCards />
      </section>
      <section className="section pricing-cta">
        <h2>Free lets you experience Cove.</h2>
        <p className="lead">
          Pro unlocks a second intelligence working for you.
        </p>
        <div className="actions centered-actions">
          <Link href="/download" className="button primary">
            <span className="icon download" aria-hidden="true" />
            Download Cove
          </Link>
          <Link href="/features" className="button secondary">
            Explore features
          </Link>
        </div>
      </section>
    </div>
  );
}

"use client";

import Link from "next/link";
import { useState } from "react";

const freeFeatures = [
  "Voice assistant",
  "Task Mode",
  "Basic memory",
  "App control",
  "Messaging",
  "File operations",
  "Cloud sync",
  "Daily usage limits",
];

const freeRestrictions = [
  "Agent Mode",
  "Persistent agents",
  "Background execution",
  "Advanced memory",
];

const proFeatures = [
  "Unlimited Task Mode",
  "Agent Mode",
  "Persistent agents",
  "Background execution",
  "Advanced memory",
  "Multi-step workflows",
  "Voice personalization",
  "Priority intelligence",
  "Advanced permissions",
];

export function PricingCards() {
  const [billing, setBilling] = useState<"monthly" | "yearly">("monthly");
  const isYearly = billing === "yearly";

  return (
    <div className="pricing-experience">
      <div className="billing-toggle" aria-label="Billing period">
        <button
          className={!isYearly ? "active" : ""}
          type="button"
          onClick={() => setBilling("monthly")}
        >
          Monthly
        </button>
        <button
          className={isYearly ? "active" : ""}
          type="button"
          onClick={() => setBilling("yearly")}
        >
          Yearly
        </button>
        <span className={isYearly ? "toggle-pill yearly" : "toggle-pill"} />
      </div>

      <div className="pricing-grid cinematic-pricing-grid">
        <article className="pricing-card">
          <div>
            <p className="plan-kicker">Experience Cove</p>
            <h3>Cove Free</h3>
            <div className="price-row">
              <span>$0</span>
            </div>
            <p className="billing-note">A personal runtime trial for everyday tasks.</p>
          </div>
          <ul className="feature-list included-list">
            {freeFeatures.map((feature) => (
              <li key={feature}>{feature}</li>
            ))}
          </ul>
          <div className="plan-divider" />
          <ul className="feature-list restricted-list">
            {freeRestrictions.map((feature) => (
              <li key={feature}>{feature}</li>
            ))}
          </ul>
          <div className="usage-limit-note">
            <strong>When the daily limit is reached</strong>
            <p>
              You&apos;ve reached today&apos;s free usage limit. Come back
              tomorrow or upgrade to Cove Pro.
            </p>
          </div>
          <Link href="/download" className="button secondary">
            Download Cove
          </Link>
        </article>

        <article className="pricing-card featured-plan">
          <div className="plan-badge">Second intelligence unlocked</div>
          <div>
            <p className="plan-kicker">Cove working for you</p>
            <h3>Cove Pro</h3>
            <div className="price-row animated-price" key={billing}>
              <span>{isYearly ? "$150" : "$15"}</span>
              <small>{isYearly ? "/year" : "/month"}</small>
            </div>
            <p className="billing-note">
              {isYearly ? "Billed yearly" : "Billed monthly"}
            </p>
          </div>
          <ul className="feature-list included-list">
            {proFeatures.map((feature) => (
              <li key={feature}>{feature}</li>
            ))}
          </ul>
          <Link href="/download" className="button primary">
            Upgrade to Pro
          </Link>
        </article>
      </div>
    </div>
  );
}

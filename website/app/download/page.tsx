import { DownloadSphere } from "../components/DownloadSphere";

const downloads = [
  {
    platform: "macOS",
    action: "Download for macOS",
    note: "Bring Cove into the place where your work already happens.",
    icon: "apple",
    available: true,
  },
  {
    platform: "Windows",
    action: "Download for Windows",
    note: "A personal AI runtime for your desktop, voice, apps, and tasks.",
    icon: "monitor",
    available: true,
  },
  {
    platform: "Linux",
    action: "Ubuntu coming soon",
    note: "Ubuntu support is on the way.",
    icon: "linux",
    available: false,
  },
];

const onboardingSteps = [
  "Install Cove",
  "Sign in",
  "Choose permissions",
  "Configure voice",
  "Start using Cove",
];

export default function DownloadPage() {
  return (
    <div className="page">
      <header className="page-header centered-header download-hero">
        <DownloadSphere />
        <div className="download-hero-copy">
          <p className="eyebrow">Download</p>
          <h1>Download Cove</h1>
          <p className="lead">Your personal AI.</p>
        </div>
      </header>

      <section className="content download-content">
        <div className="download-options">
          {downloads.map((download) => (
            <article className="download-card" key={download.platform}>
              <div className="download-card-top">
                <span className={`large-icon ${download.icon}`} aria-hidden="true" />
                <div>
                  <h3>{download.platform}</h3>
                </div>
              </div>
              <p>{download.note}</p>
              <button
                className={download.available ? "button primary" : "button secondary"}
                disabled={!download.available}
                type="button"
              >
                <span className="icon download" aria-hidden="true" />
                {download.action}
              </button>
            </article>
          ))}
        </div>

        <section className="install-flow" aria-labelledby="install-flow-title">
          <div className="section-heading centered-header">
            <p className="eyebrow">Installation</p>
            <h2 id="install-flow-title">From installer to alive in minutes.</h2>
          </div>
          <div className="install-steps">
            {onboardingSteps.map((step, index) => (
              <article className="install-step" key={step}>
                <span>{String(index + 1).padStart(2, "0")}</span>
                <h3>{step}</h3>
              </article>
            ))}
          </div>
        </section>
      </section>
    </div>
  );
}

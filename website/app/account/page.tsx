export default function AccountPage() {
  return (
    <div className="page">
      <header className="page-header">
        <p className="eyebrow">Account</p>
        <h1>Manage your Cove account.</h1>
        <p className="lead">
          Account settings support the desktop runtime: profile, plan,
          recovery, cloud sync, and trusted sign-in methods.
        </p>
      </header>
      <section className="content list">
        <div className="row">
          <div>
            <h3>Profile</h3>
            <p>Name, email, and recovery information.</p>
          </div>
          <span className="status good">Ready</span>
        </div>
        <div className="row">
          <div>
            <h3>Cloud sync</h3>
            <p>Optional encrypted sync for selected settings and memory.</p>
          </div>
          <span className="status good">Optional</span>
        </div>
        <div className="row">
          <div>
            <h3>Billing</h3>
            <p>Subscription, invoices, and workspace ownership.</p>
          </div>
          <span className="status good">Support</span>
        </div>
      </section>
    </div>
  );
}


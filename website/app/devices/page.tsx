export default function DevicesPage() {
  return (
    <div className="page">
      <header className="page-header">
        <p className="eyebrow">Devices</p>
        <h1>Trust the computers Cove can run on.</h1>
        <p className="lead">
          Device management lets users register installations, review active
          runtimes, revoke access, and verify new computers.
        </p>
      </header>
      <section className="content">
        <div className="table" role="table" aria-label="Registered devices">
          <div className="table-row" role="row">
            <h3>Device</h3>
            <h3>Platform</h3>
            <h3>Status</h3>
          </div>
          <div className="table-row" role="row">
            <p>Alex&apos;s MacBook Pro</p>
            <p>macOS</p>
            <p>Trusted</p>
          </div>
          <div className="table-row" role="row">
            <p>Studio PC</p>
            <p>Windows</p>
            <p>Verification required</p>
          </div>
        </div>
      </section>
    </div>
  );
}

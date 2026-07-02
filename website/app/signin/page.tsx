import { SignInSphere } from "../components/SignInSphere";

const providers = ["Google", "Apple", "GitHub"];

export default function SignInPage() {
  return (
    <div className="page">
      <section className="signin-split">
        <div className="signin-sphere-side">
          <SignInSphere />
        </div>
        <div className="signin-copy-side">
          <div className="signin-hero-copy">
            <p className="eyebrow">Sign In</p>
            <h1>Welcome to Cove</h1>
            <p className="lead">Continue where your intelligence left off.</p>
          </div>
          <div className="provider-list">
            {providers.map((provider) => (
              <button className="provider-button" key={provider} type="button">
                <span aria-hidden="true">{provider.slice(0, 1)}</span>
                Continue with {provider}
              </button>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}

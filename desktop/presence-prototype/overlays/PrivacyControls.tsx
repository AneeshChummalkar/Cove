import { usePresence } from "../state/presenceStore";

export function PrivacyControls() {
  const { state, actions } = usePresence();

  return (
    <section className="privacy-rail" aria-label="Privacy quick actions">
      <button className={state.privacy.paused ? "active" : ""} onClick={() => actions.togglePrivacy("paused")}>
        Pause Cove
      </button>
      <button
        className={!state.privacy.screenObservation ? "active" : ""}
        onClick={() => actions.togglePrivacy("screenObservation")}
      >
        Screen off
      </button>
      <button
        className={!state.privacy.suggestions ? "active" : ""}
        onClick={() => actions.togglePrivacy("suggestions")}
      >
        Suggestions off
      </button>
      <button className={state.privacy.privateMode ? "active" : ""} onClick={() => actions.togglePrivacy("privateMode")}>
        Private mode
      </button>
      <button className={state.privacy.offForApp ? "active" : ""} onClick={() => actions.togglePrivacy("offForApp")}>
        Off for app
      </button>
      <button className={state.privacy.offForVideo ? "active" : ""} onClick={() => actions.togglePrivacy("offForVideo")}>
        Off for video
      </button>
      <button className={state.privacy.killSwitch ? "danger active" : "danger"} onClick={() => actions.togglePrivacy("killSwitch")}>
        Kill switch
      </button>
    </section>
  );
}

import { useCovePrototype } from "../state/prototypeStore";

export function PermissionDialog() {
  const { state, dispatch } = useCovePrototype();
  const dialog = state.permissionDialog;

  if (!dialog) {
    return null;
  }

  return (
    <div className="permission-backdrop" role="presentation">
      <section className="permission-dialog" role="dialog" aria-modal="true" aria-labelledby="permission-title">
        <div className="dialog-header">
          <span className="warning-light" />
          <div>
            <h2 id="permission-title">Permission Required</h2>
            <p>{dialog.reason}</p>
          </div>
        </div>

        <dl className="permission-facts">
          <div>
            <dt>Action</dt>
            <dd>{dialog.action}</dd>
          </div>
          <div>
            <dt>Target</dt>
            <dd>{dialog.target}</dd>
          </div>
          <div>
            <dt>Mode</dt>
            <dd>{dialog.mode}</dd>
          </div>
          <div>
            <dt>Reason</dt>
            <dd>{dialog.reason}</dd>
          </div>
        </dl>

        <div className="dialog-actions">
          <button onClick={() => dispatch({ type: "RESOLVE_PERMISSION", decision: "allow" })}>Allow Once</button>
          <button className="secondary" onClick={() => dispatch({ type: "RESOLVE_PERMISSION", decision: "deny" })}>
            Deny
          </button>
          <button className="danger" onClick={() => dispatch({ type: "RESOLVE_PERMISSION", decision: "pause" })}>
            Pause Agent
          </button>
        </div>
      </section>
    </div>
  );
}

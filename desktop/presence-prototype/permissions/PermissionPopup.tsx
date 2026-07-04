import { usePresence } from "../state/presenceStore";

export function PermissionPopup() {
  const { state, actions } = usePresence();
  const request = state.permissionRequest;

  if (!request) {
    return null;
  }

  return (
    <div className="permission-popover" role="dialog" aria-label={request.title}>
      <div>
        <span>{request.app}</span>
        <strong>{request.title}</strong>
        <p>{request.reason}</p>
      </div>
      <dl>
        <div>
          <dt>Action</dt>
          <dd>{request.action}</dd>
        </div>
        <div>
          <dt>Preview</dt>
          <dd>{request.preview}</dd>
        </div>
        <div>
          <dt>Risk</dt>
          <dd>{request.risk}</dd>
        </div>
      </dl>
      <div className="permission-actions">
        <button onClick={actions.denyPermission}>Deny</button>
        <button className="primary-action" onClick={actions.approvePermission}>
          Allow
        </button>
      </div>
    </div>
  );
}

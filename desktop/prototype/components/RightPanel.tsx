import { ActivityLog } from "./ActivityLog";
import { KillSwitch } from "./KillSwitch";
import { TrustDashboard } from "./TrustDashboard";

export function RightPanel() {
  return (
    <aside className="right-panel surface">
      <ActivityLog />
      <TrustDashboard />
      <KillSwitch />
    </aside>
  );
}

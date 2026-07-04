import { AgentMode } from "../agents/AgentMode";
import { SimulationRail } from "../components/SimulationRail";
import { TrustStrip } from "../components/TrustStrip";
import { ActivitySheet } from "../memory/ActivitySheet";
import { MacNotch } from "../notch/MacNotch";
import { NotificationStack } from "../notifications/NotificationStack";
import { WindowsOrb } from "../orb/WindowsOrb";
import { CursorRuntime } from "../overlays/CursorRuntime";
import { PrivacyControls } from "../overlays/PrivacyControls";
import { PermissionPopup } from "../permissions/PermissionPopup";
import { SettingsSheet } from "../settings/SettingsSheet";
import { TaskCommandPalette } from "../task/TaskCommandPalette";
import { usePresence } from "../state/presenceStore";

export function App() {
  const { state } = usePresence();
  const platformClass = state.platform === "mac" ? "is-mac" : "is-windows";

  return (
    <main className={`overlay-runtime ${platformClass} ${state.privacy.killSwitch ? "is-stopped" : ""}`}>
      {state.platform === "mac" ? <MacNotch /> : <WindowsOrb />}
      <TaskCommandPalette />
      <AgentMode />
      <CursorRuntime />
      <PrivacyControls />
      <TrustStrip />
      <NotificationStack />
      <PermissionPopup />
      <SettingsSheet />
      <ActivitySheet />
      <SimulationRail />
    </main>
  );
}

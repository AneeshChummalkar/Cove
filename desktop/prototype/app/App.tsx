import { CenterWorkspace } from "../components/CenterWorkspace";
import { LeftSidebar } from "../components/LeftSidebar";
import { PermissionDialog } from "../components/PermissionDialog";
import { RightPanel } from "../components/RightPanel";
import { WindowsOrb } from "../components/WindowsOrb";
import { useCovePrototype } from "../state/prototypeStore";

export function App() {
  const { state } = useCovePrototype();

  return (
    <main className={`app-shell presence-${state.presenceMode.toLowerCase()} ${state.killSwitch ? "paused" : ""}`}>
      <div className="titlebar">
        <div className="brand-lockup">
          <img src="/assets/cove-mark.svg" alt="" />
          <div>
            <strong>Cove</strong>
            <span>Phase 4 simulated desktop runtime</span>
          </div>
        </div>
        <div className="runtime-pills" aria-label="Prototype constraints">
          <span>Local state</span>
          <span>Fake JSON</span>
          <span>No integrations</span>
        </div>
      </div>

      <section className="runtime-grid">
        <LeftSidebar />
        <CenterWorkspace />
        <RightPanel />
      </section>

      <WindowsOrb />
      <PermissionDialog />
    </main>
  );
}

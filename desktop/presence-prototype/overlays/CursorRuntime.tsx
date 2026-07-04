import { useEffect, useState } from "react";
import { usePresence } from "../state/presenceStore";

const suggestions = {
  PDF: "Need summary?",
  YouTube: "Summarize this lecture?",
  Gmail: "Summarize inbox?",
  VSCode: "Need help debugging?",
  WhatsApp: "Draft reply?",
  Trading: "Risk appears elevated.",
  Desktop: ""
};

export function CursorRuntime() {
  const { state, actions } = usePresence();
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    if (state.currentApp === "Desktop") {
      setVisible(false);
      return;
    }

    const showTimer = window.setTimeout(() => setVisible(true), 900);
    const hideTimer = window.setTimeout(() => setVisible(false), 5600);
    return () => {
      window.clearTimeout(showTimer);
      window.clearTimeout(hideTimer);
    };
  }, [state.currentApp]);

  const hidden =
    !visible ||
    !state.privacy.suggestions ||
    state.privacy.privateMode ||
    state.privacy.offForApp ||
    state.privacy.offForVideo ||
    state.currentApp === "Desktop";

  if (hidden) {
    return null;
  }

  return (
    <button className={`cursor-popup context-${state.currentApp.toLowerCase()}`} onClick={() => actions.runTask(cursorAction(state.currentApp))}>
      <span className="cursor-dot" />
      <strong>{suggestions[state.currentApp]}</strong>
      <small>simulated suggestion</small>
    </button>
  );
}

function cursorAction(app: string) {
  if (app === "PDF") return "Summarize PDF";
  if (app === "Gmail") return "Filter 500 emails";
  if (app === "VSCode") return "Need help debugging";
  if (app === "WhatsApp") return "Text Sudharshan";
  return "Summarize PDF";
}

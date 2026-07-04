import { useEffect, useState } from "react";
import { usePresence } from "../state/presenceStore";

const suggestions = {
  PDF: "Summarize PDF?",
  YouTube: "Summarize lecture?",
  Gmail: "Draft reply?",
  VSCode: "Explain code?",
  WhatsApp: "",
  Trading: "Security warning?",
  Desktop: ""
};

export function CursorRuntime() {
  const { state, actions } = usePresence();
  const [visible, setVisible] = useState(false);
  const [dismissedContext, setDismissedContext] = useState<string | null>(null);

  useEffect(() => {
    setDismissedContext(null);

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
    dismissedContext === state.currentApp ||
    state.currentApp === "Desktop";

  if (hidden) {
    return null;
  }

  return (
    <div className={`cursor-popup context-${state.currentApp.toLowerCase()}`}>
      <span className="cursor-dot" />
      <button className="cursor-suggestion" onClick={() => actions.runTask(cursorAction(state.currentApp))}>
        <strong>{suggestions[state.currentApp]}</strong>
        <small>context suggestion</small>
      </button>
      <button className="cursor-dismiss" onClick={() => setDismissedContext(state.currentApp)} aria-label="Dismiss suggestion">
        x
      </button>
    </div>
  );
}

function cursorAction(app: string) {
  if (app === "PDF") return "Summarize PDF";
  if (app === "YouTube") return "Summarize lecture";
  if (app === "Gmail") return "Summarize inbox";
  if (app === "VSCode") return "Need help debugging";
  return "Summarize PDF";
}

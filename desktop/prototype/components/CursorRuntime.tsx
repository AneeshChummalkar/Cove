import { CSSProperties } from "react";
import { useCovePrototype } from "../state/prototypeStore";

export function CursorRuntime() {
  const { state, data, dispatch } = useCovePrototype();
  const activeContext = data.cursorContexts.find((context) => context.id === state.cursorContextId) ?? data.cursorContexts[0];
  const suggestionsEnabled = state.presenceMode !== "GHOST" && !state.killSwitch;

  const runQuickAction = () => {
    if (activeContext.id === "pdf") {
      dispatch({ type: "START_TASK", id: "summarize-pdf" });
    } else if (activeContext.id === "gmail") {
      dispatch({ type: "START_AGENT", id: "filter-emails" });
    } else if (activeContext.id === "whatsapp") {
      dispatch({ type: "START_TASK", id: "text-sudharshan" });
    } else {
      dispatch({ type: "START_TASK", id: "open-youtube" });
    }
  };

  return (
    <section className="workspace-section cursor-runtime">
      <div className="section-heading">
        <span>Cursor Runtime</span>
        <small>{suggestionsEnabled ? data.presenceModes[state.presenceMode].popupFrequency : "quiet"}</small>
      </div>

      <div className="desktop-stage">
        {data.cursorContexts.map((context, index) => (
          <button
            key={context.id}
            className={`fake-window ${context.id} ${state.cursorContextId === context.id ? "hovered" : ""}`}
            onMouseEnter={() => dispatch({ type: "SET_CURSOR_CONTEXT", id: context.id })}
            onFocus={() => dispatch({ type: "SET_CURSOR_CONTEXT", id: context.id })}
            style={{ "--index": index } as CSSProperties}
          >
            <strong>{context.surface}</strong>
            <span>{context.detail}</span>
          </button>
        ))}

        <div className={`cursor-popup ${suggestionsEnabled ? "visible" : "muted"}`}>
          <span className="cursor-pin" />
          <strong>{suggestionsEnabled ? activeContext.prompt : "Cove quiet"}</strong>
          <small>{suggestionsEnabled ? activeContext.detail : "Ghost mode suppresses proactive suggestions."}</small>
          <button onClick={runQuickAction} disabled={!suggestionsEnabled}>
            {activeContext.quickAction}
          </button>
        </div>
      </div>
    </section>
  );
}

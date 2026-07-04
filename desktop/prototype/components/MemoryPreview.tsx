import { useState } from "react";
import { useCovePrototype } from "../state/prototypeStore";

export function MemoryPreview() {
  const { state } = useCovePrototype();
  const categories = Object.keys(state.memory);
  const [activeCategory, setActiveCategory] = useState(categories[0]);

  return (
    <section className="workspace-section memory-preview">
      <div className="section-heading">
        <span>Agent Memory</span>
        <small>{activeCategory}</small>
      </div>
      <div className="memory-layout">
        <div className="memory-tabs">
          {categories.map((category) => (
            <button
              key={category}
              className={activeCategory === category ? "selected" : ""}
              onClick={() => setActiveCategory(category)}
            >
              {category}
            </button>
          ))}
        </div>
        <ul className="memory-list">
          {state.memory[activeCategory].map((item) => (
            <li key={item}>{item}</li>
          ))}
        </ul>
      </div>
    </section>
  );
}

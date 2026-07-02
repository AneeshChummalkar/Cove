import { IntelligentSphere } from "./IntelligentSphere";

const labels = ["Voice", "Tasks", "Agents", "Memory", "Permissions", "Runtime"];

export function FeaturesSphere() {
  return (
    <IntelligentSphere
      centerTitle="Cove"
      centerSubtitle="Runtime"
      className="features-sphere-wrap"
      labels={labels}
    />
  );
}

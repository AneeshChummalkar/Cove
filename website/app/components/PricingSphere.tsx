import { IntelligentSphere } from "./IntelligentSphere";

export function PricingSphere() {
  return (
    <IntelligentSphere
      centerTitle="Pro"
      centerSubtitle="Agents"
      className="pricing-sphere-wrap"
      labels={["Free", "Pro"]}
    />
  );
}

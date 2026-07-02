import { IntelligentSphere } from "./IntelligentSphere";

export function DownloadSphere() {
  return (
    <IntelligentSphere
      centerTitle="Cove"
      centerSubtitle="Personal AI"
      className="download-sphere-wrap"
      labels={["macOS", "Windows"]}
      particleCount={4}
    />
  );
}

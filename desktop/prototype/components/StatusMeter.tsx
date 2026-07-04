export function StatusMeter({ value, label }: { value: number; label: string }) {
  return (
    <div className="status-meter" aria-label={label}>
      <div className="meter-track">
        <span style={{ width: `${Math.max(0, Math.min(100, value))}%` }} />
      </div>
      <small>{value}%</small>
    </div>
  );
}

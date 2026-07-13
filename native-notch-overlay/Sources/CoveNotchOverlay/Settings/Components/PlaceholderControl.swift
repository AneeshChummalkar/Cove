import AppKit

/// Wraps a not-yet-functional control with a consistent disabled look and a
/// small "SOON" badge, so placeholder items read intentionally across every
/// section rather than looking broken.
enum PlaceholderControl {
  static func wrap(_ control: NSView) -> NSView {
    if let control = control as? NSControl {
      control.isEnabled = false
    }
    control.alphaValue = 0.5
    control.translatesAutoresizingMaskIntoConstraints = false

    let badge = SettingsBadge("SOON")

    let stack = NSStackView(views: [control, badge])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.orientation = .horizontal
    stack.spacing = 8
    stack.alignment = .centerY

    NSLayoutConstraint.activate([
      badge.widthAnchor.constraint(equalToConstant: 44)
    ])

    return stack
  }
}

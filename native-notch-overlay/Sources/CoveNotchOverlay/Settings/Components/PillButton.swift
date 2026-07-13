import AppKit

enum PillButtonStyle {
  case filled
  case tinted
  case destructive
}

/// A rounded, full-width capable button used for auth actions and primary
/// controls throughout Settings. Deliberately not `NSButton.bezelStyle`
/// system chrome, so the app keeps its own identity.
final class PillButton: NSButton {
  private let style: PillButtonStyle
  private var hoverTrackingArea: NSTrackingArea?

  init(title: String, symbolName: String? = nil, style: PillButtonStyle = .tinted) {
    self.style = style
    super.init(frame: .zero)
    self.title = title
    translatesAutoresizingMaskIntoConstraints = false
    isBordered = false
    wantsLayer = true
    layer?.cornerRadius = SettingsTheme.pillCornerRadius
    layer?.cornerCurve = .continuous
    font = .systemFont(ofSize: 12.5, weight: .semibold)
    contentTintColor = .labelColor

    if let symbolName {
      image = NSImage(systemSymbolName: symbolName, accessibilityDescription: title)
      imagePosition = .imageLeading
      imageHugsTitle = true
    }

    applyStyle()
    heightAnchor.constraint(equalToConstant: 34).isActive = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func applyStyle() {
    layer?.borderWidth = 0
    switch style {
    case .filled:
      layer?.backgroundColor = SettingsTheme.accent.cgColor
      contentTintColor = .white
    case .tinted:
      layer?.backgroundColor = SettingsTheme.controlFill(for: self).cgColor
      layer?.borderWidth = 1
      layer?.borderColor = SettingsTheme.subtleBorder(for: self).cgColor
    case .destructive:
      layer?.backgroundColor = NSColor.systemRed.withAlphaComponent(0.12).cgColor
      contentTintColor = .systemRed
    }
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    applyStyle()
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    if let hoverTrackingArea {
      removeTrackingArea(hoverTrackingArea)
    }
    let trackingArea = NSTrackingArea(
      rect: bounds,
      options: [.activeInKeyWindow, .mouseEnteredAndExited],
      owner: self,
      userInfo: nil
    )
    addTrackingArea(trackingArea)
    hoverTrackingArea = trackingArea
  }

  override func mouseEntered(with event: NSEvent) {
    guard isEnabled else { return }
    animator().alphaValue = 0.82
  }

  override func mouseExited(with event: NSEvent) {
    animator().alphaValue = isEnabled ? 1 : 0.45
  }

  override var isEnabled: Bool {
    didSet {
      alphaValue = isEnabled ? 1 : 0.45
    }
  }
}

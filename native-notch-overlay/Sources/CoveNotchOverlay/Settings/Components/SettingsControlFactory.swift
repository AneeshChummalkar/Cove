import AppKit

/// Small control recipes used by multiple sections. Keeping placeholder
/// construction here prevents each page from inventing a different disabled
/// state while real services are still being built.
enum SettingsControlFactory {
  static func placeholderSwitch(isOn: Bool = false) -> NSView {
    let control = NSSwitch()
    control.state = isOn ? .on : .off
    return PlaceholderControl.wrap(control)
  }

  static func placeholderButton(
    title: String,
    symbolName: String? = nil,
    style: PillButtonStyle = .tinted
  ) -> NSView {
    PlaceholderControl.wrap(PillButton(title: title, symbolName: symbolName, style: style))
  }

  static func placeholderPopup(title: String, width: CGFloat = 190) -> NSView {
    let popup = NSPopUpButton(frame: .zero, pullsDown: false)
    popup.addItem(withTitle: title)
    popup.widthAnchor.constraint(equalToConstant: width).isActive = true
    return PlaceholderControl.wrap(popup)
  }

  static func placeholderSecureField(width: CGFloat = 210) -> NSView {
    let field = NSSecureTextField()
    field.placeholderString = "Enter API key"
    field.widthAnchor.constraint(equalToConstant: width).isActive = true
    field.heightAnchor.constraint(equalToConstant: 28).isActive = true
    return PlaceholderControl.wrap(field)
  }
}

/// Compact value/status treatment for read-only metadata and future states.
final class SettingsBadge: NSView {
  enum Tone {
    case neutral
    case accent
  }

  private let tone: Tone

  init(_ text: String, tone: Tone = .neutral) {
    self.tone = tone
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    wantsLayer = true
    layer?.cornerRadius = 8
    layer?.cornerCurve = .continuous

    let label = NSTextField(labelWithString: text)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 10.5, weight: .semibold)
    label.textColor = tone == .accent ? SettingsTheme.accent : .secondaryLabelColor

    addSubview(label)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 9),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -9),
      label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
      label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
    ])
    updateSurface()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    updateSurface()
  }

  private func updateSurface() {
    switch tone {
    case .neutral:
      layer?.backgroundColor = SettingsTheme.controlFill(for: self).cgColor
    case .accent:
      layer?.backgroundColor = SettingsTheme.accent.withAlphaComponent(0.14).cgColor
    }
  }
}

import AppKit

/// A single permission's status card: icon, name, description, status badge,
/// and an action button. Status values are placeholders — real TCC/permission
/// queries land in a later phase.
final class PermissionCard: NSView {
  init(symbolName: String, name: String, description: String, status: String, actionTitle: String) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    buildView(
      symbolName: symbolName,
      name: name,
      description: description,
      status: status,
      actionTitle: actionTitle
    )
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func buildView(
    symbolName: String,
    name: String,
    description: String,
    status: String,
    actionTitle: String
  ) {
    wantsLayer = true
    layer?.cornerRadius = SettingsTheme.controlCornerRadius
    layer?.cornerCurve = .continuous
    layer?.borderWidth = 1
    SettingsTheme.updateRoundedSurface(self, elevated: true)

    let iconBackground = NSView()
    iconBackground.translatesAutoresizingMaskIntoConstraints = false
    iconBackground.wantsLayer = true
    iconBackground.layer?.cornerRadius = 9
    iconBackground.layer?.cornerCurve = .continuous
    iconBackground.layer?.backgroundColor = SettingsTheme.accent.withAlphaComponent(0.15).cgColor

    let icon = NSImageView(image: NSImage(systemSymbolName: symbolName, accessibilityDescription: name) ?? NSImage())
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.contentTintColor = SettingsTheme.accent
    icon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)

    iconBackground.addSubview(icon)
    NSLayoutConstraint.activate([
      iconBackground.widthAnchor.constraint(equalToConstant: 34),
      iconBackground.heightAnchor.constraint(equalToConstant: 34),
      icon.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
      icon.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor)
    ])

    let nameLabel = NSTextField(labelWithString: name)
    nameLabel.font = SettingsTheme.rowTitleFont
    nameLabel.textColor = .labelColor

    let descriptionLabel = NSTextField(wrappingLabelWithString: description)
    descriptionLabel.font = SettingsTheme.rowSubtitleFont
    descriptionLabel.textColor = .secondaryLabelColor
    descriptionLabel.maximumNumberOfLines = 2

    let textStack = NSStackView(views: [nameLabel, descriptionLabel])
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.orientation = .vertical
    textStack.alignment = .leading
    textStack.spacing = 2

    let statusBadge = SettingsBadge(status)

    let actionButton = PillButton(title: actionTitle, style: .tinted)
    actionButton.isEnabled = false
    actionButton.toolTip = "Permission controls will be connected in a future release."

    addSubview(iconBackground)
    addSubview(textStack)
    addSubview(statusBadge)
    addSubview(actionButton)

    NSLayoutConstraint.activate([
      iconBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
      iconBackground.centerYAnchor.constraint(equalTo: centerYAnchor),

      textStack.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
      textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
      textStack.trailingAnchor.constraint(lessThanOrEqualTo: statusBadge.leadingAnchor, constant: -12),

      statusBadge.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -10),
      statusBadge.centerYAnchor.constraint(equalTo: centerYAnchor),
      statusBadge.heightAnchor.constraint(equalToConstant: 22),
      statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 92),

      actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
      actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),

      heightAnchor.constraint(equalToConstant: 66)
    ])
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    SettingsTheme.updateRoundedSurface(self, elevated: true)
  }
}

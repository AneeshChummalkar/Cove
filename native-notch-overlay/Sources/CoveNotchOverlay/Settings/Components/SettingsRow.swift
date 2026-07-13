import AppKit

/// A single title/subtitle row with a trailing accessory control. Used across
/// every section for consistent label + control alignment.
final class SettingsRow: NSView {
  init(title: String, subtitle: String? = nil, accessory: NSView? = nil) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    buildView(title: title, subtitle: subtitle, accessory: accessory)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  private func buildView(title: String, subtitle: String?, accessory: NSView?) {
    let titleLabel = NSTextField(labelWithString: title)
    titleLabel.font = SettingsTheme.rowTitleFont
    titleLabel.textColor = .labelColor
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    let textStack = NSStackView(views: [titleLabel])
    textStack.orientation = .vertical
    textStack.alignment = .leading
    textStack.spacing = 2
    textStack.translatesAutoresizingMaskIntoConstraints = false

    if let subtitle {
      let subtitleLabel = NSTextField(wrappingLabelWithString: subtitle)
      subtitleLabel.font = SettingsTheme.rowSubtitleFont
      subtitleLabel.textColor = .secondaryLabelColor
      textStack.addArrangedSubview(subtitleLabel)
    }

    addSubview(textStack)
    NSLayoutConstraint.activate([
      textStack.leadingAnchor.constraint(equalTo: leadingAnchor),
      textStack.topAnchor.constraint(equalTo: topAnchor),
      textStack.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    if let accessory {
      accessory.translatesAutoresizingMaskIntoConstraints = false
      addSubview(accessory)
      NSLayoutConstraint.activate([
        accessory.trailingAnchor.constraint(equalTo: trailingAnchor),
        accessory.centerYAnchor.constraint(equalTo: centerYAnchor),
        textStack.trailingAnchor.constraint(
          lessThanOrEqualTo: accessory.leadingAnchor, constant: -16
        )
      ])
    } else {
      textStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
  }
}

import AppKit

/// A rounded glass card used to group related rows within a section.
final class SettingsCard: NSView {
  let stackView = NSStackView()

  private let effectView = NSVisualEffectView()

  init(title: String? = nil) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    buildView(title: title)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    buildView(title: nil)
  }

  private func buildView(title: String?) {
    effectView.translatesAutoresizingMaskIntoConstraints = false
    effectView.material = .contentBackground
    effectView.blendingMode = .withinWindow
    effectView.state = .followsWindowActiveState
    SettingsTheme.configureRoundedSurface(effectView)

    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.orientation = .vertical
    stackView.alignment = .leading
    stackView.spacing = SettingsTheme.rowSpacing
    stackView.edgeInsets = NSEdgeInsets(
      top: SettingsTheme.cardPadding,
      left: SettingsTheme.cardPadding,
      bottom: SettingsTheme.cardPadding,
      right: SettingsTheme.cardPadding
    )

    if let title {
      let label = NSTextField(labelWithString: title.uppercased())
      label.font = SettingsTheme.cardTitleFont
      label.textColor = .tertiaryLabelColor
      stackView.addArrangedSubview(label)
    }

    addSubview(effectView)
    addSubview(stackView)

    NSLayoutConstraint.activate([
      effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
      effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
      effectView.topAnchor.constraint(equalTo: topAnchor),
      effectView.bottomAnchor.constraint(equalTo: bottomAnchor),

      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    SettingsTheme.updateRoundedSurface(effectView)
  }

  func addRow(_ view: NSView) {
    stackView.addArrangedSubview(view)
    constrainToContentWidth(view)
  }

  func addDivider() {
    let divider = NSBox()
    divider.boxType = .separator
    stackView.addArrangedSubview(divider)
    constrainToContentWidth(divider)
  }

  private func constrainToContentWidth(_ view: NSView) {
    view.widthAnchor.constraint(
      equalTo: widthAnchor, constant: -(SettingsTheme.cardPadding * 2)
    ).isActive = true
  }
}

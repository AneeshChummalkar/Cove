import AppKit

/// Arc/Linear-style segmented control: a track with an animated sliding
/// selection pill, used for Appearance and the AI provider picker.
final class PillSegmentedControl: NSView {
  private(set) var selectedIndex: Int
  var onChange: ((Int) -> Void)?

  private let indicator = NSView()
  private let stackView = NSStackView()
  private var buttons: [NSButton] = []

  init(items: [String], selectedIndex: Int = 0) {
    self.selectedIndex = selectedIndex
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    buildView(items: items)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func buildView(items: [String]) {
    wantsLayer = true
    layer?.cornerRadius = SettingsTheme.controlCornerRadius
    layer?.cornerCurve = .continuous
    updateSurface()

    indicator.translatesAutoresizingMaskIntoConstraints = true
    indicator.wantsLayer = true
    indicator.layer?.cornerRadius = max(SettingsTheme.controlCornerRadius - 3, 4)
    indicator.layer?.cornerCurve = .continuous
    indicator.layer?.backgroundColor = SettingsTheme.accent.cgColor
    addSubview(indicator)

    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.orientation = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 0
    addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
      heightAnchor.constraint(equalToConstant: 32)
    ])

    for (index, item) in items.enumerated() {
      let button = NSButton(title: item, target: self, action: #selector(segmentPressed(_:)))
      button.tag = index
      button.isBordered = false
      button.font = .systemFont(ofSize: 12, weight: .medium)
      button.contentTintColor = index == selectedIndex ? .white : .labelColor
      stackView.addArrangedSubview(button)
      buttons.append(button)
    }
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    updateSurface()
    updateTintColors()
  }

  private func updateSurface() {
    layer?.backgroundColor = SettingsTheme.controlFill(for: self).cgColor
    layer?.borderWidth = 1
    layer?.borderColor = SettingsTheme.subtleBorder(for: self).cgColor
    indicator.layer?.backgroundColor = SettingsTheme.accent.cgColor
  }

  override func layout() {
    super.layout()
    positionIndicator(animated: false)
  }

  @objc private func segmentPressed(_ sender: NSButton) {
    guard sender.tag != selectedIndex else { return }
    selectedIndex = sender.tag
    updateTintColors()
    positionIndicator(animated: true)
    onChange?(selectedIndex)
  }

  private func updateTintColors() {
    for button in buttons {
      button.contentTintColor = button.tag == selectedIndex ? .white : .labelColor
    }
  }

  private func positionIndicator(animated: Bool) {
    guard buttons.indices.contains(selectedIndex) else { return }
    let button = buttons[selectedIndex]
    let targetFrame = stackView.convert(button.frame, to: self)
    guard targetFrame.width > 0 else { return }

    if animated {
      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.28
        context.timingFunction = CAMediaTimingFunction(name: .easeOut)
        indicator.animator().frame = targetFrame
      }
    } else {
      indicator.frame = targetFrame
    }
  }
}

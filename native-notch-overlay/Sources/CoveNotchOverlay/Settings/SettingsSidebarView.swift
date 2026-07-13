import AppKit

protocol SettingsSidebarViewDelegate: AnyObject {
  func settingsSidebar(_ sidebar: SettingsSidebarView, didSelect section: SettingsSection)
}

/// Custom glass sidebar with an animated selection pill. Intentionally not
/// an NSOutlineView/NSTableView source list, so it doesn't read as a System
/// Settings clone.
final class SettingsSidebarView: NSView {
  weak var delegate: SettingsSidebarViewDelegate?
  private(set) var selectedSection: SettingsSection

  private let selectionIndicator = NSView()
  private let stackView = NSStackView()
  private var rowButtons: [SettingsSection: SidebarRowButton] = [:]

  init(selected: SettingsSection) {
    self.selectedSection = selected
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    buildView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func buildView() {
    let effectView = NSVisualEffectView()
    effectView.material = .sidebar
    effectView.blendingMode = .behindWindow
    effectView.state = .followsWindowActiveState
    effectView.translatesAutoresizingMaskIntoConstraints = false

    selectionIndicator.translatesAutoresizingMaskIntoConstraints = true
    selectionIndicator.wantsLayer = true
    selectionIndicator.layer?.cornerRadius = SettingsTheme.controlCornerRadius
    selectionIndicator.layer?.cornerCurve = .continuous
    updateSelectionSurface()

    let markBackground = NSView()
    markBackground.translatesAutoresizingMaskIntoConstraints = false
    SettingsTheme.configureRoundedSurface(markBackground, radius: 10)

    let mark = NSImageView(
      image: NSImage(systemSymbolName: "waveform.path.ecg", accessibilityDescription: "Cove") ?? NSImage()
    )
    mark.translatesAutoresizingMaskIntoConstraints = false
    mark.contentTintColor = SettingsTheme.accent
    mark.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
    markBackground.addSubview(mark)

    let appTitle = NSTextField(labelWithString: "Cove")
    appTitle.font = .systemFont(ofSize: 15, weight: .bold)
    appTitle.textColor = .labelColor
    appTitle.translatesAutoresizingMaskIntoConstraints = false

    let eyebrow = NSTextField(labelWithString: "SETTINGS")
    eyebrow.font = .systemFont(ofSize: 9.5, weight: .bold)
    eyebrow.textColor = .tertiaryLabelColor
    eyebrow.translatesAutoresizingMaskIntoConstraints = false

    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.orientation = .vertical
    stackView.alignment = .leading
    stackView.spacing = 2

    for section in SettingsSection.allCases {
      let button = SidebarRowButton(section: section)
      button.isSelectedRow = section == selectedSection
      button.target = self
      button.action = #selector(rowPressed(_:))
      stackView.addArrangedSubview(button)
      button.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
      rowButtons[section] = button
    }

    addSubview(effectView)
    addSubview(selectionIndicator)
    addSubview(markBackground)
    addSubview(appTitle)
    addSubview(eyebrow)
    addSubview(stackView)

    NSLayoutConstraint.activate([
      effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
      effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
      effectView.topAnchor.constraint(equalTo: topAnchor),
      effectView.bottomAnchor.constraint(equalTo: bottomAnchor),

      markBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
      markBackground.topAnchor.constraint(equalTo: topAnchor, constant: 48),
      markBackground.widthAnchor.constraint(equalToConstant: 34),
      markBackground.heightAnchor.constraint(equalToConstant: 34),

      mark.centerXAnchor.constraint(equalTo: markBackground.centerXAnchor),
      mark.centerYAnchor.constraint(equalTo: markBackground.centerYAnchor),

      appTitle.leadingAnchor.constraint(equalTo: markBackground.trailingAnchor, constant: 10),
      appTitle.topAnchor.constraint(equalTo: markBackground.topAnchor, constant: 1),

      eyebrow.leadingAnchor.constraint(equalTo: appTitle.leadingAnchor),
      eyebrow.topAnchor.constraint(equalTo: appTitle.bottomAnchor, constant: 1),

      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      stackView.topAnchor.constraint(equalTo: markBackground.bottomAnchor, constant: 24)
    ])
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    updateSelectionSurface()
  }

  private func updateSelectionSurface() {
    selectionIndicator.layer?.backgroundColor = SettingsTheme.accent.withAlphaComponent(0.16).cgColor
    selectionIndicator.layer?.borderWidth = 1
    selectionIndicator.layer?.borderColor = SettingsTheme.accent.withAlphaComponent(0.12).cgColor
  }

  @objc private func rowPressed(_ sender: SidebarRowButton) {
    guard sender.section != selectedSection else { return }
    let previous = selectedSection
    selectedSection = sender.section
    rowButtons[previous]?.isSelectedRow = false
    rowButtons[selectedSection]?.isSelectedRow = true
    positionIndicator(animated: true)
    delegate?.settingsSidebar(self, didSelect: selectedSection)
  }

  override func layout() {
    super.layout()
    positionIndicator(animated: false)
  }

  private func positionIndicator(animated: Bool) {
    guard let button = rowButtons[selectedSection], button.frame != .zero else { return }
    let targetFrame = stackView.convert(button.frame, to: self)

    if animated {
      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.24
        context.timingFunction = CAMediaTimingFunction(name: .easeOut)
        selectionIndicator.animator().frame = targetFrame
      }
    } else {
      selectionIndicator.frame = targetFrame
    }
  }
}

private final class SidebarRowButton: NSButton {
  let section: SettingsSection
  var isSelectedRow = false {
    didSet { updateAppearance() }
  }

  init(section: SettingsSection) {
    self.section = section
    super.init(frame: .zero)
    title = section.title
    image = NSImage(systemSymbolName: section.symbolName, accessibilityDescription: section.title)
    imagePosition = .imageLeading
    imageHugsTitle = true
    imageScaling = .scaleProportionallyDown
    isBordered = false
    alignment = .left
    translatesAutoresizingMaskIntoConstraints = false
    heightAnchor.constraint(equalToConstant: 34).isActive = true
    updateAppearance()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func updateAppearance() {
    contentTintColor = isSelectedRow ? SettingsTheme.accent : .secondaryLabelColor
    font = .systemFont(ofSize: 13, weight: isSelectedRow ? .semibold : .medium)
  }
}

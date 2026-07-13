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
    print("[Settings][Sidebar Init 01] SettingsSidebarView.init() started:", selected.title)
    super.init(frame: .zero)
    print("[Settings][Sidebar Init 02] NSView.init returned")
    translatesAutoresizingMaskIntoConstraints = false
    print("[Settings][Sidebar Init 03] Auto-resizing mask translation disabled")
    print("[Settings][Sidebar Init 04] Calling buildView()")
    buildView()
    print("[Settings][Sidebar Init 05] buildView() returned")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func buildView() {
    print("[Settings][Sidebar Build 01] Creating sidebar NSVisualEffectView")
    let effectView = NSVisualEffectView()
    print("[Settings][Sidebar Build 02] Sidebar NSVisualEffectView created")
    effectView.material = .sidebar
    effectView.blendingMode = .behindWindow
    effectView.state = .followsWindowActiveState
    effectView.translatesAutoresizingMaskIntoConstraints = false
    print("[Settings][Sidebar Build 03] Sidebar NSVisualEffectView configured")

    selectionIndicator.translatesAutoresizingMaskIntoConstraints = true
    selectionIndicator.wantsLayer = true
    selectionIndicator.layer?.cornerRadius = SettingsTheme.controlCornerRadius
    selectionIndicator.layer?.cornerCurve = .continuous
    updateSelectionSurface()
    print("[Settings][Sidebar Build 04] Selection indicator configured")

    let markBackground = NSView()
    print("[Settings][Sidebar Build 05] Mark background created")
    markBackground.translatesAutoresizingMaskIntoConstraints = false
    SettingsTheme.configureRoundedSurface(markBackground, radius: 10)
    print("[Settings][Sidebar Build 06] Mark background configured")

    print("[Settings][Sidebar Build 07] Resolving Cove system symbol")
    let markImage = NSImage(systemSymbolName: "waveform.path.ecg", accessibilityDescription: "Cove")
    print("[Settings][Sidebar Build 08] Cove system symbol resolved:", markImage != nil)
    let mark = NSImageView(
      image: markImage ?? NSImage()
    )
    print("[Settings][Sidebar Build 09] Mark image view created")
    mark.translatesAutoresizingMaskIntoConstraints = false
    mark.contentTintColor = SettingsTheme.accent
    mark.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
    markBackground.addSubview(mark)
    print("[Settings][Sidebar Build 10] Mark image view configured and added")

    let appTitle = NSTextField(labelWithString: "Cove")
    print("[Settings][Sidebar Build 11] App title created")
    appTitle.font = .systemFont(ofSize: 15, weight: .bold)
    appTitle.textColor = .labelColor
    appTitle.translatesAutoresizingMaskIntoConstraints = false

    let eyebrow = NSTextField(labelWithString: "SETTINGS")
    print("[Settings][Sidebar Build 12] Eyebrow created")
    eyebrow.font = .systemFont(ofSize: 9.5, weight: .bold)
    eyebrow.textColor = .tertiaryLabelColor
    eyebrow.translatesAutoresizingMaskIntoConstraints = false

    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.orientation = .vertical
    stackView.alignment = .leading
    stackView.spacing = 2
    print("[Settings][Sidebar Build 13] Sidebar stack configured")

    for section in SettingsSection.allCases {
      print("[Settings][Sidebar Build 14] Creating row:", section.title)
      let button = SidebarRowButton(section: section)
      print("[Settings][Sidebar Build 15] Row created:", section.title)
      button.isSelectedRow = section == selectedSection
      button.target = self
      button.action = #selector(rowPressed(_:))
      stackView.addArrangedSubview(button)
      button.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
      rowButtons[section] = button
      print("[Settings][Sidebar Build 16] Row configured and added:", section.title)
    }

    addSubview(effectView)
    addSubview(selectionIndicator)
    addSubview(markBackground)
    addSubview(appTitle)
    addSubview(eyebrow)
    addSubview(stackView)
    print("[Settings][Sidebar Build 17] Sidebar subviews added")

    print("[Settings][Sidebar Build 18] Activating sidebar constraints")
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
    print("[Settings][Sidebar Build 19] Sidebar constraints activated")
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

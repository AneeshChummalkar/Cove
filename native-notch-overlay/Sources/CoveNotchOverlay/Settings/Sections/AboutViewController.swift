import AppKit

final class AboutViewController: BaseSectionViewController {
  override var sectionTitle: String { "About" }
  override var sectionSubtitle: String? {
    "Cove is a private, desktop-first runtime for personal AI."
  }

  override func buildContent() {
    let identityCard = SettingsCard()
    identityCard.addRow(AboutIdentityView())
    addCard(identityCard)

    let buildCard = SettingsCard(title: "Build")
    buildCard.addRow(SettingsRow(
      title: "Cove Version",
      accessory: SettingsBadge(versionString, tone: .accent)
    ))
    buildCard.addDivider()
    buildCard.addRow(SettingsRow(
      title: "Build Number",
      accessory: SettingsBadge(buildNumber)
    ))
    addCard(buildCard)

    let resourcesCard = SettingsCard(title: "Resources")
    resourcesCard.addRow(SettingsRow(
      title: "GitHub",
      subtitle: "View Cove's source repository.",
      accessory: linkButton(title: "Open", action: #selector(openGitHub))
    ))
    resourcesCard.addDivider()
    resourcesCard.addRow(SettingsRow(
      title: "Documentation",
      subtitle: "Read Cove's architecture and product documentation.",
      accessory: linkButton(title: "Open", action: #selector(openDocumentation))
    ))
    resourcesCard.addDivider()
    resourcesCard.addRow(SettingsRow(
      title: "Privacy Policy",
      subtitle: "A published policy will be linked before public distribution.",
      accessory: SettingsControlFactory.placeholderButton(title: "View")
    ))
    resourcesCard.addDivider()
    resourcesCard.addRow(SettingsRow(
      title: "Licenses",
      subtitle: "Third-party notices and software licenses.",
      accessory: SettingsControlFactory.placeholderButton(title: "View")
    ))
    addCard(resourcesCard)
  }

  private var versionString: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
  }

  private var buildNumber: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Development"
  }

  private func linkButton(title: String, action: Selector) -> NSButton {
    let button = PillButton(title: title, symbolName: "arrow.up.right", style: .tinted)
    button.target = self
    button.action = action
    return button
  }

  @objc private func openGitHub() {
    openURL("https://github.com/AneeshChummalkar/Cove")
  }

  @objc private func openDocumentation() {
    openURL("https://github.com/AneeshChummalkar/Cove/tree/main/docs")
  }

  private func openURL(_ string: String) {
    guard let url = URL(string: string) else { return }
    NSWorkspace.shared.open(url)
  }
}

private final class AboutIdentityView: NSView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    translatesAutoresizingMaskIntoConstraints = false

    let markBackground = NSView()
    markBackground.translatesAutoresizingMaskIntoConstraints = false
    markBackground.wantsLayer = true
    markBackground.layer?.cornerRadius = 15
    markBackground.layer?.cornerCurve = .continuous
    markBackground.layer?.backgroundColor = SettingsTheme.accent.withAlphaComponent(0.16).cgColor

    let mark = NSImageView(
      image: NSImage(systemSymbolName: "waveform.path.ecg", accessibilityDescription: "Cove") ?? NSImage()
    )
    mark.translatesAutoresizingMaskIntoConstraints = false
    mark.contentTintColor = SettingsTheme.accent
    mark.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    markBackground.addSubview(mark)

    let title = NSTextField(labelWithString: "Cove")
    title.font = .systemFont(ofSize: 18, weight: .bold)
    title.textColor = .labelColor

    let subtitle = NSTextField(labelWithString: "Personal AI, grounded on your Mac.")
    subtitle.font = SettingsTheme.rowSubtitleFont
    subtitle.textColor = .secondaryLabelColor

    let labels = NSStackView(views: [title, subtitle])
    labels.translatesAutoresizingMaskIntoConstraints = false
    labels.orientation = .vertical
    labels.alignment = .leading
    labels.spacing = 3

    addSubview(markBackground)
    addSubview(labels)
    NSLayoutConstraint.activate([
      markBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
      markBackground.centerYAnchor.constraint(equalTo: centerYAnchor),
      markBackground.widthAnchor.constraint(equalToConstant: 54),
      markBackground.heightAnchor.constraint(equalToConstant: 54),
      mark.centerXAnchor.constraint(equalTo: markBackground.centerXAnchor),
      mark.centerYAnchor.constraint(equalTo: markBackground.centerYAnchor),

      labels.leadingAnchor.constraint(equalTo: markBackground.trailingAnchor, constant: 14),
      labels.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
      labels.centerYAnchor.constraint(equalTo: centerYAnchor),
      heightAnchor.constraint(greaterThanOrEqualToConstant: 58)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

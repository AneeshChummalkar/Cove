import AppKit

final class AccountViewController: BaseSectionViewController {
  override var sectionTitle: String { "Account" }
  override var sectionSubtitle: String? {
    "Your identity, Cove plan, and connected services will live here."
  }

  override func buildContent() {
    let profileCard = SettingsCard(title: "Profile")
    profileCard.addRow(ProfilePlaceholderView())
    profileCard.addDivider()
    profileCard.addRow(SettingsRow(
      title: "Sign Out",
      subtitle: "Available after an account is connected.",
      accessory: SettingsControlFactory.placeholderButton(title: "Sign Out", style: .destructive)
    ))
    addCard(profileCard)

    let authenticationCard = SettingsCard(title: "Continue with")
    authenticationCard.addRow(authenticationButton(
      title: "Continue with Apple",
      symbolName: "apple.logo",
      style: .filled
    ))
    authenticationCard.addRow(authenticationButton(
      title: "Continue with Google",
      symbolName: "globe",
      style: .tinted
    ))
    authenticationCard.addRow(authenticationButton(
      title: "Continue with GitHub",
      symbolName: "chevron.left.forwardslash.chevron.right",
      style: .tinted
    ))

    let authNote = NSTextField(
      wrappingLabelWithString: "Authentication services are not connected in this foundation build."
    )
    authNote.font = SettingsTheme.rowSubtitleFont
    authNote.textColor = .tertiaryLabelColor
    authenticationCard.addRow(authNote)
    addCard(authenticationCard)

    let planCard = SettingsCard(title: "Subscription & Plan")
    planCard.addRow(SettingsRow(
      title: "Current Plan",
      subtitle: "Plan details and billing will appear here after sign-in.",
      accessory: SettingsBadge("COVE PREVIEW", tone: .accent)
    ))
    planCard.addDivider()
    planCard.addRow(SettingsRow(
      title: "Manage Subscription",
      subtitle: "Review billing, usage, and plan options.",
      accessory: SettingsControlFactory.placeholderButton(title: "Manage")
    ))
    addCard(planCard)
  }

  private func authenticationButton(
    title: String,
    symbolName: String,
    style: PillButtonStyle
  ) -> NSView {
    let button = PillButton(title: title, symbolName: symbolName, style: style)
    button.isEnabled = false
    button.toolTip = "Authentication will be connected in a future release."
    return button
  }
}

private final class ProfilePlaceholderView: NSView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    translatesAutoresizingMaskIntoConstraints = false

    let avatar = NSView()
    avatar.translatesAutoresizingMaskIntoConstraints = false
    avatar.wantsLayer = true
    avatar.layer?.cornerRadius = 24
    avatar.layer?.cornerCurve = .continuous
    avatar.layer?.backgroundColor = SettingsTheme.accent.withAlphaComponent(0.15).cgColor

    let avatarIcon = NSImageView(
      image: NSImage(systemSymbolName: "person.fill", accessibilityDescription: "Profile") ?? NSImage()
    )
    avatarIcon.translatesAutoresizingMaskIntoConstraints = false
    avatarIcon.contentTintColor = SettingsTheme.accent
    avatarIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 18, weight: .medium)
    avatar.addSubview(avatarIcon)

    let name = NSTextField(labelWithString: "Your Cove profile")
    name.font = .systemFont(ofSize: 14, weight: .semibold)
    name.textColor = .labelColor

    let detail = NSTextField(labelWithString: "Sign in to sync identity and plan details.")
    detail.font = SettingsTheme.rowSubtitleFont
    detail.textColor = .secondaryLabelColor

    let textStack = NSStackView(views: [name, detail])
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.orientation = .vertical
    textStack.alignment = .leading
    textStack.spacing = 3

    let status = SettingsBadge("NOT CONNECTED")

    addSubview(avatar)
    addSubview(textStack)
    addSubview(status)
    NSLayoutConstraint.activate([
      avatar.leadingAnchor.constraint(equalTo: leadingAnchor),
      avatar.centerYAnchor.constraint(equalTo: centerYAnchor),
      avatar.widthAnchor.constraint(equalToConstant: 48),
      avatar.heightAnchor.constraint(equalToConstant: 48),
      avatarIcon.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
      avatarIcon.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),

      textStack.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 13),
      textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
      textStack.trailingAnchor.constraint(lessThanOrEqualTo: status.leadingAnchor, constant: -12),

      status.trailingAnchor.constraint(equalTo: trailingAnchor),
      status.centerYAnchor.constraint(equalTo: centerYAnchor),
      heightAnchor.constraint(greaterThanOrEqualToConstant: 54)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

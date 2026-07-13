import AppKit

final class AccountViewController: BaseSectionViewController {
  override var sectionTitle: String { "Account" }
  override var sectionSubtitle: String? {
    "Your identity, Cove plan, and connected services will live here."
  }

  override func buildContent() {
    print("[Settings][Account Build 01] Creating Profile card")
    let profileCard = SettingsCard(title: "Profile")
    print("[Settings][Account Build 02] Profile card created")
    profileCard.addRow(ProfilePlaceholderView())
    print("[Settings][Account Build 03] Profile placeholder row added")
    profileCard.addDivider()
    profileCard.addRow(SettingsRow(
      title: "Sign Out",
      subtitle: "Available after an account is connected.",
      accessory: SettingsControlFactory.placeholderButton(title: "Sign Out", style: .destructive)
    ))
    print("[Settings][Account Build 04] Sign Out row added")
    addCard(profileCard)
    print("[Settings][Account Build 05] Profile card added to section")

    print("[Settings][Account Build 06] Creating authentication card")
    let authenticationCard = SettingsCard(title: "Continue with")
    print("[Settings][Account Build 07] Authentication card created")
    authenticationCard.addRow(authenticationButton(
      title: "Continue with Apple",
      symbolName: "apple.logo",
      style: .filled
    ))
    print("[Settings][Account Build 08] Apple authentication row added")
    authenticationCard.addRow(authenticationButton(
      title: "Continue with Google",
      symbolName: "globe",
      style: .tinted
    ))
    print("[Settings][Account Build 09] Google authentication row added")
    authenticationCard.addRow(authenticationButton(
      title: "Continue with GitHub",
      symbolName: "chevron.left.forwardslash.chevron.right",
      style: .tinted
    ))
    print("[Settings][Account Build 10] GitHub authentication row added")

    let authNote = NSTextField(
      wrappingLabelWithString: "Authentication services are not connected in this foundation build."
    )
    authNote.font = SettingsTheme.rowSubtitleFont
    authNote.textColor = .tertiaryLabelColor
    authenticationCard.addRow(authNote)
    print("[Settings][Account Build 11] Authentication note added")
    addCard(authenticationCard)
    print("[Settings][Account Build 12] Authentication card added to section")

    print("[Settings][Account Build 13] Creating plan card")
    let planCard = SettingsCard(title: "Subscription & Plan")
    print("[Settings][Account Build 14] Plan card created")
    planCard.addRow(SettingsRow(
      title: "Current Plan",
      subtitle: "Plan details and billing will appear here after sign-in.",
      accessory: SettingsBadge("COVE PREVIEW", tone: .accent)
    ))
    print("[Settings][Account Build 15] Current Plan row added")
    planCard.addDivider()
    planCard.addRow(SettingsRow(
      title: "Manage Subscription",
      subtitle: "Review billing, usage, and plan options.",
      accessory: SettingsControlFactory.placeholderButton(title: "Manage")
    ))
    print("[Settings][Account Build 16] Manage Subscription row added")
    addCard(planCard)
    print("[Settings][Account Build 17] Plan card added to section")
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
    print("[Settings][Profile Init 01] ProfilePlaceholderView.init() started")
    super.init(frame: frameRect)
    print("[Settings][Profile Init 02] NSView.init returned")
    translatesAutoresizingMaskIntoConstraints = false

    let avatar = NSView()
    print("[Settings][Profile Init 03] Avatar view created")
    avatar.translatesAutoresizingMaskIntoConstraints = false
    avatar.wantsLayer = true
    avatar.layer?.cornerRadius = 24
    avatar.layer?.cornerCurve = .continuous
    avatar.layer?.backgroundColor = SettingsTheme.accent.withAlphaComponent(0.15).cgColor
    print("[Settings][Profile Init 04] Avatar view configured")

    print("[Settings][Profile Init 05] Resolving profile system symbol")
    let profileImage = NSImage(systemSymbolName: "person.fill", accessibilityDescription: "Profile")
    print("[Settings][Profile Init 06] Profile system symbol resolved:", profileImage != nil)
    let avatarIcon = NSImageView(
      image: profileImage ?? NSImage()
    )
    print("[Settings][Profile Init 07] Avatar image view created")
    avatarIcon.translatesAutoresizingMaskIntoConstraints = false
    avatarIcon.contentTintColor = SettingsTheme.accent
    avatarIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 18, weight: .medium)
    avatar.addSubview(avatarIcon)
    print("[Settings][Profile Init 08] Avatar image configured and added")

    let name = NSTextField(labelWithString: "Your Cove profile")
    name.font = .systemFont(ofSize: 14, weight: .semibold)
    name.textColor = .labelColor

    let detail = NSTextField(labelWithString: "Sign in to sync identity and plan details.")
    detail.font = SettingsTheme.rowSubtitleFont
    detail.textColor = .secondaryLabelColor

    let textStack = NSStackView(views: [name, detail])
    print("[Settings][Profile Init 09] Profile text stack created")
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.orientation = .vertical
    textStack.alignment = .leading
    textStack.spacing = 3

    let status = SettingsBadge("NOT CONNECTED")
    print("[Settings][Profile Init 10] Profile status badge created")

    addSubview(avatar)
    addSubview(textStack)
    addSubview(status)
    print("[Settings][Profile Init 11] Profile subviews added")
    print("[Settings][Profile Init 12] Activating profile constraints")
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
    print("[Settings][Profile Init 13] Profile constraints activated")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

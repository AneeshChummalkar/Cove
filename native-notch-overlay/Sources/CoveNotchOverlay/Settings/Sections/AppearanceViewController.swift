import AppKit

final class AppearanceViewController: BaseSectionViewController {
  override var sectionTitle: String { "Appearance" }
  override var sectionSubtitle: String? {
    "Choose how Cove feels across its native desktop surfaces."
  }

  override func buildContent() {
    let modeCard = SettingsCard(title: "Theme")
    let selector = PillSegmentedControl(
      items: ["System", "Light", "Dark"],
      selectedIndex: selectedAppearanceIndex
    )
    selector.onChange = { index in
      let modes: [AppearanceMode] = [.system, .light, .dark]
      guard modes.indices.contains(index) else { return }
      SettingsStore.shared.appearanceMode = modes[index]
    }
    modeCard.addRow(selector)
    modeCard.addRow(SettingsRow(
      title: "System Appearance",
      subtitle: "System follows your Mac. Light and Dark remain fixed until changed.",
      accessory: SettingsBadge("LIVE", tone: .accent)
    ))
    addCard(modeCard)

    let foundationCard = SettingsCard(title: "Interface")
    foundationCard.addRow(SettingsRow(
      title: "Native Glass",
      subtitle: "Cove uses AppKit vibrancy, adaptive materials, and accessible system typography.",
      accessory: SettingsBadge("ENABLED", tone: .accent)
    ))
    foundationCard.addDivider()
    foundationCard.addRow(SettingsRow(
      title: "Motion",
      subtitle: "Section changes and controls use short, responsive transitions.",
      accessory: SettingsBadge("SMOOTH")
    ))
    addCard(foundationCard)
  }

  private var selectedAppearanceIndex: Int {
    switch SettingsStore.shared.appearanceMode {
    case .system: return 0
    case .light: return 1
    case .dark: return 2
    }
  }
}

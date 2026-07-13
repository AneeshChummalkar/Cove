import AppKit

final class GeneralViewController: BaseSectionViewController {
  override var sectionTitle: String { "General" }
  override var sectionSubtitle: String? {
    "Shape how Cove starts, stays current, and fits into your daily workflow."
  }

  override func buildContent() {
    let startupCard = SettingsCard(title: "Startup")
    startupCard.addRow(SettingsRow(
      title: "Launch at Login",
      subtitle: "Start Cove automatically when you sign in to this Mac.",
      accessory: SettingsControlFactory.placeholderSwitch()
    ))
    startupCard.addDivider()
    startupCard.addRow(SettingsRow(
      title: "Startup Behavior",
      subtitle: "Choose whether Cove starts quietly or shows its presence surface.",
      accessory: SettingsControlFactory.placeholderPopup(title: "Start quietly")
    ))
    addCard(startupCard)

    let updatesCard = SettingsCard(title: "Updates")
    updatesCard.addRow(SettingsRow(
      title: "Auto Updates",
      subtitle: "Download signed Cove updates automatically when available.",
      accessory: SettingsControlFactory.placeholderSwitch(isOn: true)
    ))
    updatesCard.addDivider()
    updatesCard.addRow(SettingsRow(
      title: "Update Channel",
      subtitle: "Future builds can support stable and preview release channels.",
      accessory: SettingsBadge("STABLE")
    ))
    addCard(updatesCard)

    let shortcutsCard = SettingsCard(title: "Keyboard")
    shortcutsCard.addRow(SettingsRow(
      title: "Keyboard Shortcuts",
      subtitle: "Configure global shortcuts for Cove, voice input, and quick actions.",
      accessory: SettingsControlFactory.placeholderButton(
        title: "Configure",
        symbolName: "keyboard"
      )
    ))
    addCard(shortcutsCard)
  }
}

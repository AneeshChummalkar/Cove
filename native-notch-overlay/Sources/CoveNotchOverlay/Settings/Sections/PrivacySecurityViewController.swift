import AppKit

final class PrivacySecurityViewController: BaseSectionViewController {
  override var sectionTitle: String { "Privacy & Security" }
  override var sectionSubtitle: String? {
    "Control how Cove stores local context and reports diagnostic information."
  }

  override func buildContent() {
    let memoryCard = SettingsCard(title: "Local Memory")
    memoryCard.addRow(SettingsRow(
      title: "Local Memory",
      subtitle: "Keep stable preferences and context on this Mac.",
      accessory: SettingsControlFactory.placeholderSwitch(isOn: true)
    ))
    memoryCard.addDivider()
    memoryCard.addRow(SettingsRow(
      title: "Clear Memory",
      subtitle: "Delete Cove's locally stored memory after review and confirmation.",
      accessory: SettingsControlFactory.placeholderButton(title: "Clear", style: .destructive)
    ))
    addCard(memoryCard)

    let diagnosticsCard = SettingsCard(title: "Diagnostics")
    diagnosticsCard.addRow(SettingsRow(
      title: "Share Diagnostics",
      subtitle: "Future crash and performance reports will always exclude personal content by default.",
      accessory: SettingsControlFactory.placeholderSwitch()
    ))
    diagnosticsCard.addDivider()
    diagnosticsCard.addRow(SettingsRow(
      title: "Diagnostic History",
      subtitle: "Inspect what Cove has recorded before anything leaves this Mac.",
      accessory: SettingsControlFactory.placeholderButton(title: "Review")
    ))
    addCard(diagnosticsCard)
  }
}

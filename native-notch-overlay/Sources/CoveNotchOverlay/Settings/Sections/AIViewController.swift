import AppKit

final class AIViewController: BaseSectionViewController {
  override var sectionTitle: String { "AI" }
  override var sectionSubtitle: String? {
    "Prepare Cove's reasoning layer for cloud or local providers."
  }

  override func buildContent() {
    let providerCard = SettingsCard(title: "Provider")
    let providerSelector = PillSegmentedControl(
      items: ["OpenAI", "Claude", "Gemini", "Local (Ollama)"],
      selectedIndex: selectedProviderIndex
    )
    providerSelector.onChange = { index in
      let providers: [AIProvider] = [.openAI, .claude, .gemini, .local]
      guard providers.indices.contains(index) else { return }
      SettingsStore.shared.aiProvider = providers[index]
    }
    providerCard.addRow(providerSelector)
    providerCard.addRow(SettingsRow(
      title: "Active Provider",
      subtitle: "Selection is saved locally. Provider connections are not active yet.",
      accessory: SettingsBadge("FOUNDATION", tone: .accent)
    ))
    addCard(providerCard)

    let configurationCard = SettingsCard(title: "Configuration")
    configurationCard.addRow(SettingsRow(
      title: "Model",
      subtitle: "Available models will be loaded from the selected provider.",
      accessory: SettingsControlFactory.placeholderPopup(title: "Choose a model")
    ))
    configurationCard.addDivider()
    configurationCard.addRow(SettingsRow(
      title: "API Key",
      subtitle: "Credentials will be stored securely in the macOS Keychain.",
      accessory: SettingsControlFactory.placeholderSecureField()
    ))
    addCard(configurationCard)

    let runtimeCard = SettingsCard(title: "Future Runtime")
    runtimeCard.addRow(SettingsRow(
      title: "Agent Mode",
      subtitle: "Allow long-running goals with visible status, scope, and interruption controls.",
      accessory: SettingsControlFactory.placeholderSwitch()
    ))
    runtimeCard.addDivider()
    runtimeCard.addRow(SettingsRow(
      title: "Memory",
      subtitle: "Let the selected provider use approved local memories as context.",
      accessory: SettingsControlFactory.placeholderSwitch()
    ))
    addCard(runtimeCard)
  }

  private var selectedProviderIndex: Int {
    switch SettingsStore.shared.aiProvider {
    case .openAI: return 0
    case .claude: return 1
    case .gemini: return 2
    case .local: return 3
    }
  }
}

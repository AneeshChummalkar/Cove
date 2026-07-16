import AppKit

final class AIViewController: BaseSectionViewController, NSTextFieldDelegate {
  private let modelPopup = NSPopUpButton(frame: .zero, pullsDown: false)
  private let apiKeyField = NSSecureTextField()
  private let testConnectionButton = PillButton(title: "Test Connection", style: .tinted)
  private let openAIClient = OpenAIClient()
  private var isTestingConnection = false

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
    providerSelector.onChange = { [weak self] index in
      let providers: [AIProvider] = [.openAI, .claude, .gemini, .local]
      guard providers.indices.contains(index) else { return }
      self?.saveAPIKey(for: SettingsStore.shared.aiProvider)
      SettingsStore.shared.aiProvider = providers[index]
      self?.updateConfigurationControls()
    }
    providerCard.addRow(providerSelector)
    providerCard.addRow(SettingsRow(
      title: "Active Provider",
      subtitle: "Selection and provider configuration are saved locally.",
      accessory: SettingsBadge("FOUNDATION", tone: .accent)
    ))
    addCard(providerCard)

    let configurationCard = SettingsCard(title: "Configuration")
    configureModelPopup()
    configurationCard.addRow(SettingsRow(
      title: "Model",
      subtitle: "Choose the model used by the selected provider.",
      accessory: modelPopup
    ))
    configurationCard.addDivider()
    configureAPIKeyField()
    configurationCard.addRow(SettingsRow(
      title: "API Key",
      subtitle: "Credentials will be stored securely in the macOS Keychain.",
      accessory: apiKeyField
    ))
    configurationCard.addDivider()
    configureTestConnectionButton()
    configurationCard.addRow(SettingsRow(
      title: "Connection",
      subtitle: "Verify the saved API key and selected provider model.",
      accessory: testConnectionButton
    ))
    addCard(configurationCard)
    updateConfigurationControls()

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

  func controlTextDidEndEditing(_ notification: Notification) {
    guard notification.object as? NSSecureTextField === apiKeyField else { return }
    saveAPIKey(for: SettingsStore.shared.aiProvider)
  }

  func controlTextDidChange(_ notification: Notification) {
    guard notification.object as? NSSecureTextField === apiKeyField else { return }
    updateTestConnectionButton()
  }

  private func configureModelPopup() {
    modelPopup.target = self
    modelPopup.action = #selector(modelChanged)
    modelPopup.widthAnchor.constraint(equalToConstant: 190).isActive = true
  }

  private func configureAPIKeyField() {
    apiKeyField.placeholderString = "Enter API key"
    apiKeyField.delegate = self
    apiKeyField.widthAnchor.constraint(equalToConstant: 210).isActive = true
    apiKeyField.heightAnchor.constraint(equalToConstant: 28).isActive = true
  }

  private func configureTestConnectionButton() {
    testConnectionButton.target = self
    testConnectionButton.action = #selector(testConnection)
  }

  private func updateConfigurationControls() {
    let provider = SettingsStore.shared.aiProvider
    let models = models(for: provider)
    modelPopup.removeAllItems()
    modelPopup.addItems(withTitles: models.map(\.displayName))
    let selectedModel = selectedModelRawValue(for: provider)
    modelPopup.selectItem(at: models.firstIndex { $0.rawValue == selectedModel } ?? 0)
    apiKeyField.stringValue = apiKey(for: provider) ?? ""
    updateTestConnectionButton()
  }

  private func saveAPIKey(for provider: AIProvider) {
    switch provider {
    case .openAI: SettingsStore.shared.openAIAPIKey = apiKeyField.stringValue
    case .claude: SettingsStore.shared.claudeAPIKey = apiKeyField.stringValue
    case .gemini: SettingsStore.shared.geminiAPIKey = apiKeyField.stringValue
    case .local: SettingsStore.shared.ollamaAPIKey = apiKeyField.stringValue
    }
  }

  @objc private func modelChanged() {
    let provider = SettingsStore.shared.aiProvider
    let models = models(for: provider)
    guard models.indices.contains(modelPopup.indexOfSelectedItem) else { return }
    let rawValue = models[modelPopup.indexOfSelectedItem].rawValue
    switch provider {
    case .openAI:
      if let model = OpenAIModel(rawValue: rawValue) { SettingsStore.shared.openAIModel = model }
    case .claude:
      if let model = ClaudeModel(rawValue: rawValue) { SettingsStore.shared.claudeModel = model }
    case .gemini:
      if let model = GeminiModel(rawValue: rawValue) { SettingsStore.shared.geminiModel = model }
    case .local:
      if let model = OllamaModel(rawValue: rawValue) { SettingsStore.shared.ollamaModel = model }
    }
  }

  @objc private func testConnection() {
    guard !isTestingConnection else { return }
    let provider = SettingsStore.shared.aiProvider
    saveAPIKey(for: provider)

    guard provider == .openAI else {
      showAlert(
        message: "Connection testing for this provider is not implemented yet.",
        information: "",
        style: .informational
      )
      return
    }

    isTestingConnection = true
    testConnectionButton.title = "Testing..."
    updateTestConnectionButton()
    let selectedModel = SettingsStore.shared.openAIModel.displayName

    openAIClient.send(input: "Hello") { [weak self] result in
      DispatchQueue.main.async {
        guard let self else { return }
        self.isTestingConnection = false
        self.testConnectionButton.title = "Test Connection"
        self.updateTestConnectionButton()

        switch result {
        case .success(let response):
          self.showAlert(
            message: "Connected successfully.",
            information: "Model: \(selectedModel)\nResponse ID: \(response.id)",
            style: .informational
          )
        case .failure(let error):
          self.showAlert(
            message: "Connection failed.",
            information: error.localizedDescription,
            style: .warning
          )
        }
      }
    }
  }

  private func updateTestConnectionButton() {
    let hasAPIKey = !apiKeyField.stringValue
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .isEmpty
    testConnectionButton.isEnabled = hasAPIKey && !isTestingConnection
  }

  private func models(for provider: AIProvider) -> [(rawValue: String, displayName: String)] {
    switch provider {
    case .openAI:
      return OpenAIModel.allCases.map { ($0.rawValue, $0.displayName) }
    case .claude:
      return ClaudeModel.allCases.map { ($0.rawValue, $0.displayName) }
    case .gemini:
      return GeminiModel.allCases.map { ($0.rawValue, $0.displayName) }
    case .local:
      return OllamaModel.allCases.map { ($0.rawValue, $0.displayName) }
    }
  }

  private func selectedModelRawValue(for provider: AIProvider) -> String {
    switch provider {
    case .openAI: return SettingsStore.shared.openAIModel.rawValue
    case .claude: return SettingsStore.shared.claudeModel.rawValue
    case .gemini: return SettingsStore.shared.geminiModel.rawValue
    case .local: return SettingsStore.shared.ollamaModel.rawValue
    }
  }

  private func apiKey(for provider: AIProvider) -> String? {
    switch provider {
    case .openAI: return SettingsStore.shared.openAIAPIKey
    case .claude: return SettingsStore.shared.claudeAPIKey
    case .gemini: return SettingsStore.shared.geminiAPIKey
    case .local: return SettingsStore.shared.ollamaAPIKey
    }
  }

  private func showAlert(message: String, information: String, style: NSAlert.Style) {
    let alert = NSAlert()
    alert.messageText = message
    alert.informativeText = information
    alert.alertStyle = style
    alert.addButton(withTitle: "OK")

    if let window = view.window {
      alert.beginSheetModal(for: window)
    } else {
      alert.runModal()
    }
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

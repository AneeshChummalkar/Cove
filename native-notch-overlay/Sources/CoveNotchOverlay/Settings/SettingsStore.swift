import AppKit
import Security

enum AppearanceMode: String {
  case system
  case light
  case dark
}

enum AIProvider: String {
  case openAI
  case claude
  case gemini
  case local
}

enum OpenAIModel: String, CaseIterable {
  case gpt5 = "gpt-5"
  case gpt5Mini = "gpt-5-mini"
  case gpt5Nano = "gpt-5-nano"

  var displayName: String {
    switch self {
    case .gpt5: return "GPT-5"
    case .gpt5Mini: return "GPT-5 mini"
    case .gpt5Nano: return "GPT-5 nano"
    }
  }
}

enum ClaudeModel: String, CaseIterable {
  case opus = "claude-opus-4-1"
  case sonnet = "claude-sonnet-4-0"
  case haiku = "claude-3-5-haiku-latest"

  var displayName: String {
    switch self {
    case .opus: return "Claude Opus 4.1"
    case .sonnet: return "Claude Sonnet 4"
    case .haiku: return "Claude Haiku 3.5"
    }
  }
}

enum GeminiModel: String, CaseIterable {
  case pro = "gemini-2.5-pro"
  case flash = "gemini-2.5-flash"
  case flashLite = "gemini-2.5-flash-lite"

  var displayName: String {
    switch self {
    case .pro: return "Gemini 2.5 Pro"
    case .flash: return "Gemini 2.5 Flash"
    case .flashLite: return "Gemini 2.5 Flash Lite"
    }
  }
}

enum OllamaModel: String, CaseIterable {
  case llama = "llama3.2"
  case mistral
  case gemma = "gemma3"

  var displayName: String {
    switch self {
    case .llama: return "Llama 3.2"
    case .mistral: return "Mistral"
    case .gemma: return "Gemma 3"
    }
  }
}

/// Small persisted-state singleton for the Settings experience. Appearance
/// and provider selection are real/persisted today; future services can grow
/// this store without coupling view controllers to UserDefaults.
final class SettingsStore {
  static let shared = SettingsStore()

  private let defaults = UserDefaults.standard
  private let appearanceModeKey = "cove.settings.appearanceMode"
  private let aiProviderKey = "cove.settings.aiProvider"
  private let openAIModelKey = "cove.settings.openAIModel"
  private let claudeModelKey = "cove.settings.claudeModel"
  private let geminiModelKey = "cove.settings.geminiModel"
  private let ollamaModelKey = "cove.settings.ollamaModel"

  private init() {}

  var appearanceMode: AppearanceMode {
    get {
      AppearanceMode(rawValue: defaults.string(forKey: appearanceModeKey) ?? "") ?? .system
    }
    set {
      defaults.set(newValue.rawValue, forKey: appearanceModeKey)
      applyAppearance(newValue)
    }
  }

  var aiProvider: AIProvider {
    get {
      AIProvider(rawValue: defaults.string(forKey: aiProviderKey) ?? "") ?? .openAI
    }
    set {
      defaults.set(newValue.rawValue, forKey: aiProviderKey)
    }
  }

  var openAIModel: OpenAIModel {
    get {
      OpenAIModel(rawValue: defaults.string(forKey: openAIModelKey) ?? "") ?? .gpt5
    }
    set {
      defaults.set(newValue.rawValue, forKey: openAIModelKey)
    }
  }

  var claudeModel: ClaudeModel {
    get {
      ClaudeModel(rawValue: defaults.string(forKey: claudeModelKey) ?? "") ?? .sonnet
    }
    set {
      defaults.set(newValue.rawValue, forKey: claudeModelKey)
    }
  }

  var geminiModel: GeminiModel {
    get {
      GeminiModel(rawValue: defaults.string(forKey: geminiModelKey) ?? "") ?? .flash
    }
    set {
      defaults.set(newValue.rawValue, forKey: geminiModelKey)
    }
  }

  var ollamaModel: OllamaModel {
    get {
      OllamaModel(rawValue: defaults.string(forKey: ollamaModelKey) ?? "") ?? .llama
    }
    set {
      defaults.set(newValue.rawValue, forKey: ollamaModelKey)
    }
  }

  var openAIAPIKey: String? {
    get { apiKey(service: "com.cove.openai") }
    set { setAPIKey(newValue, service: "com.cove.openai") }
  }

  var claudeAPIKey: String? {
    get { apiKey(service: "com.cove.claude") }
    set { setAPIKey(newValue, service: "com.cove.claude") }
  }

  var geminiAPIKey: String? {
    get { apiKey(service: "com.cove.gemini") }
    set { setAPIKey(newValue, service: "com.cove.gemini") }
  }

  var ollamaAPIKey: String? {
    get { apiKey(service: "com.cove.ollama") }
    set { setAPIKey(newValue, service: "com.cove.ollama") }
  }

  func applyPersistedAppearance() {
    applyAppearance(appearanceMode)
  }

  private func applyAppearance(_ mode: AppearanceMode) {
    switch mode {
    case .system:
      NSApp.appearance = nil
    case .light:
      NSApp.appearance = NSAppearance(named: .aqua)
    case .dark:
      NSApp.appearance = NSAppearance(named: .darkAqua)
    }
  }

  private func apiKey(service: String) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: "api-key",
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var result: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
          let data = result as? Data else { return nil }
    return String(data: data, encoding: .utf8)
  }

  private func setAPIKey(_ apiKey: String?, service: String) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: "api-key"
    ]

    guard let apiKey, !apiKey.isEmpty else {
      SecItemDelete(query as CFDictionary)
      return
    }

    let attributes: [String: Any] = [
      kSecValueData as String: Data(apiKey.utf8),
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    if status == errSecItemNotFound {
      var item = query
      attributes.forEach { item[$0.key] = $0.value }
      SecItemAdd(item as CFDictionary, nil)
    }
  }
}

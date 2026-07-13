import AppKit

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

/// Small persisted-state singleton for the Settings experience. Appearance
/// and provider selection are real/persisted today; future services can grow
/// this store without coupling view controllers to UserDefaults.
final class SettingsStore {
  static let shared = SettingsStore()

  private let defaults = UserDefaults.standard
  private let appearanceModeKey = "cove.settings.appearanceMode"
  private let aiProviderKey = "cove.settings.aiProvider"

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
}

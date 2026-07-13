import AppKit

enum SettingsSection: Int, CaseIterable {
  case account
  case appearance
  case privacySecurity
  case permissions
  case ai
  case general
  case about

  var title: String {
    switch self {
    case .account: return "Account"
    case .appearance: return "Appearance"
    case .privacySecurity: return "Privacy & Security"
    case .permissions: return "Permissions"
    case .ai: return "AI"
    case .general: return "General"
    case .about: return "About"
    }
  }

  var symbolName: String {
    switch self {
    case .account: return "person.crop.circle"
    case .appearance: return "paintbrush.fill"
    case .privacySecurity: return "lock.shield.fill"
    case .permissions: return "checkerboard.shield"
    case .ai: return "sparkles"
    case .general: return "gearshape.fill"
    case .about: return "info.circle.fill"
    }
  }

  func makeViewController() -> NSViewController {
    switch self {
    case .account: return AccountViewController()
    case .appearance: return AppearanceViewController()
    case .privacySecurity: return PrivacySecurityViewController()
    case .permissions: return PermissionsViewController()
    case .ai: return AIViewController()
    case .general: return GeneralViewController()
    case .about: return AboutViewController()
    }
  }
}

import AppKit

/// Shared design tokens for the Settings experience. Centralizing these keeps
/// every section visually consistent and makes future sections cheap to add.
enum SettingsTheme {
  static let windowSize = NSSize(width: 940, height: 640)
  static let minimumWindowSize = NSSize(width: 780, height: 560)
  static let sidebarWidth: CGFloat = 228

  static let cardCornerRadius: CGFloat = 16
  static let controlCornerRadius: CGFloat = 10
  static let pillCornerRadius: CGFloat = 9

  static let contentInset: CGFloat = 32
  static let cardSpacing: CGFloat = 14
  static let cardPadding: CGFloat = 18
  static let rowSpacing: CGFloat = 12
  static let sectionTransitionDuration: TimeInterval = 0.22

  static let accent = NSColor.controlAccentColor

  static let titleFont = NSFont.systemFont(ofSize: 24, weight: .semibold)
  static let subtitleFont = NSFont.systemFont(ofSize: 12.5, weight: .regular)
  static let cardTitleFont = NSFont.systemFont(ofSize: 12, weight: .semibold)
  static let rowTitleFont = NSFont.systemFont(ofSize: 13, weight: .medium)
  static let rowSubtitleFont = NSFont.systemFont(ofSize: 11.5, weight: .regular)

  static func configureRoundedSurface(_ view: NSView, radius: CGFloat = cardCornerRadius) {
    view.wantsLayer = true
    view.layer?.cornerRadius = radius
    view.layer?.cornerCurve = .continuous
    view.layer?.masksToBounds = true
    view.layer?.borderWidth = 1
    updateRoundedSurface(view)
  }

  static func updateRoundedSurface(_ view: NSView, elevated: Bool = false) {
    let isDark = view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    view.layer?.backgroundColor = (isDark
      ? NSColor.white.withAlphaComponent(elevated ? 0.075 : 0.05)
      : NSColor.white.withAlphaComponent(elevated ? 0.68 : 0.48)).cgColor
    view.layer?.borderColor = (isDark
      ? NSColor.white.withAlphaComponent(0.09)
      : NSColor.black.withAlphaComponent(0.07)).cgColor
  }

  static func controlFill(for view: NSView) -> NSColor {
    let isDark = view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    return isDark
      ? NSColor.white.withAlphaComponent(0.08)
      : NSColor.black.withAlphaComponent(0.055)
  }

  static func subtleBorder(for view: NSView) -> NSColor {
    let isDark = view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    return isDark
      ? NSColor.white.withAlphaComponent(0.11)
      : NSColor.black.withAlphaComponent(0.08)
  }
}

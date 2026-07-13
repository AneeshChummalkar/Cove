import AppKit

/// Owns Cove's single Settings window. The window is retained by AppDelegate,
/// so reopening it preserves the selected section and scroll position.
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
  private var hasPresented = false

  init() {
    let rootViewController = SettingsContainerViewController()
    let window = NSWindow(
      contentRect: NSRect(origin: .zero, size: SettingsTheme.windowSize),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )

    window.title = "Cove Settings"
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.backgroundColor = .clear
    window.isOpaque = false
    window.hasShadow = true
    window.minSize = SettingsTheme.minimumWindowSize
    window.contentViewController = rootViewController
    window.animationBehavior = .documentWindow
    window.collectionBehavior = [.managed, .participatesInCycle]
    window.setFrameAutosaveName("CoveSettingsWindow")

    super.init(window: window)
    window.delegate = self
    shouldCascadeWindows = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func present() {
    guard let window else { return }
    SettingsStore.shared.applyPersistedAppearance()

    if !hasPresented && !window.setFrameUsingName("CoveSettingsWindow") {
      window.center()
    }
    hasPresented = true

    NSApp.activate(ignoringOtherApps: true)
    showWindow(nil)
    window.makeKeyAndOrderFront(nil)
  }
}

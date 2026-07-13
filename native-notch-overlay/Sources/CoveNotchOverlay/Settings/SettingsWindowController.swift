import AppKit

/// Owns Cove's single Settings window. The window is retained by AppDelegate,
/// so reopening it preserves the selected section and scroll position.
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
  private var hasPresented = false

  init() {
    print("[Settings] SettingsWindowController.init() started")
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
    window.alphaValue = 1
    window.isReleasedWhenClosed = false
    window.minSize = SettingsTheme.minimumWindowSize
    window.contentViewController = rootViewController
    window.animationBehavior = .documentWindow
    window.collectionBehavior = [.managed, .participatesInCycle]
    window.setFrameAutosaveName("CoveSettingsWindow")

    super.init(window: window)
    window.delegate = self
    shouldCascadeWindows = false
    print("[Settings] SettingsWindowController.init() completed:", [
      "controller": String(describing: ObjectIdentifier(self)),
      "window": String(describing: ObjectIdentifier(window)),
      "frame": NSStringFromRect(window.frame),
      "alpha": window.alphaValue,
      "visible": window.isVisible
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    print("[Settings] SettingsWindowController deinitialized:", String(describing: ObjectIdentifier(self)))
  }

  func present() {
    print("[Settings] present() entered:", String(describing: ObjectIdentifier(self)))
    guard let window else {
      print("[Settings] present() aborted: NSWindowController.window is nil")
      return
    }
    SettingsStore.shared.applyPersistedAppearance()

    if !hasPresented {
      let restoredFrame = window.setFrameUsingName("CoveSettingsWindow")
      print("[Settings] Window frame restoration:", [
        "restored": restoredFrame,
        "frame": NSStringFromRect(window.frame)
      ])
      if !restoredFrame {
        window.center()
        print("[Settings] No saved frame; centered window:", NSStringFromRect(window.frame))
      }
    }
    hasPresented = true

    ensureWindowIsOnScreen(window)
    window.alphaValue = 1
    window.isReleasedWhenClosed = false

    printWindowState(window, step: "before activation")
    NSApp.activate(ignoringOtherApps: true)
    NSApp.unhide(nil)
    showWindow(nil)
    if window.isMiniaturized {
      window.deminiaturize(nil)
    }
    window.makeKeyAndOrderFront(nil)
    window.orderFrontRegardless()
    printWindowState(window, step: "after makeKeyAndOrderFront")

    DispatchQueue.main.async { [weak self, weak window] in
      guard let self, let window else {
        print("[Settings] Deferred visibility check failed: controller or window was released")
        return
      }
      self.printWindowState(window, step: "next run-loop visibility check")
    }
  }

  private func ensureWindowIsOnScreen(_ window: NSWindow) {
    let visibleFrames = NSScreen.screens.map(\.visibleFrame)
    let isOnScreen = visibleFrames.contains { visibleFrame in
      visibleFrame.intersection(window.frame).width > 80 &&
        visibleFrame.intersection(window.frame).height > 80
    }

    print("[Settings] Window screen-position check:", [
      "frame": NSStringFromRect(window.frame),
      "visibleFrames": visibleFrames.map(NSStringFromRect),
      "isOnScreen": isOnScreen
    ])

    if !isOnScreen {
      window.center()
      print("[Settings] Recentered off-screen window:", NSStringFromRect(window.frame))
    }
  }

  private func printWindowState(_ window: NSWindow, step: String) {
    print("[Settings] Window state — \(step):", [
      "controller": String(describing: ObjectIdentifier(self)),
      "window": String(describing: ObjectIdentifier(window)),
      "frame": NSStringFromRect(window.frame),
      "alpha": window.alphaValue,
      "visible": window.isVisible,
      "miniaturized": window.isMiniaturized,
      "key": window.isKeyWindow,
      "main": window.isMainWindow,
      "appActive": NSApp.isActive,
      "appHidden": NSApp.isHidden,
      "screen": window.screen?.localizedName ?? "none"
    ])
  }
}

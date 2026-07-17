import AppKit

/// Owns Cove's single Settings window. The window is retained by AppDelegate,
/// so reopening it preserves the selected section and scroll position.
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
  private var hasPresented = false
  private var chatWindowController: ChatWindowController?

  init() {
    print("[Settings][Init 01] SettingsWindowController.init() started")
    print("[Settings][Init 02] Creating SettingsContainerViewController")
    let rootViewController = SettingsContainerViewController()
    print("[Settings][Init 03] SettingsContainerViewController created")

    print("[Settings][Init 04] Creating NSWindow")
    let window = NSWindow(
      contentRect: NSRect(origin: .zero, size: SettingsTheme.windowSize),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )
    print("[Settings][Init 05] NSWindow created:", NSStringFromRect(window.frame))

    window.title = "Cove Settings"
    print("[Settings][Init 06] Window title assigned")
    window.titleVisibility = .hidden
    print("[Settings][Init 07] Window title visibility assigned")
    window.titlebarAppearsTransparent = true
    print("[Settings][Init 08] Transparent titlebar enabled")
    window.backgroundColor = .clear
    print("[Settings][Init 09] Window background assigned")
    window.isOpaque = false
    print("[Settings][Init 10] Window opacity mode assigned")
    window.hasShadow = true
    print("[Settings][Init 11] Window shadow enabled")
    window.alphaValue = 1
    print("[Settings][Init 12] Window alpha assigned:", window.alphaValue)
    window.isReleasedWhenClosed = false
    print("[Settings][Init 13] Window release behavior assigned")
    window.minSize = SettingsTheme.minimumWindowSize
    window.contentMinSize = SettingsTheme.minimumWindowSize
    print("[Settings][Init 14] Window minimum size assigned:", NSStringFromSize(window.minSize))

    print("[Settings][Init 15] Assigning window.contentViewController")
    window.contentViewController = rootViewController
    print("[Settings][Init 16] window.contentViewController assigned")
    window.animationBehavior = .documentWindow
    print("[Settings][Init 17] Window animation behavior assigned")
    window.collectionBehavior = [.managed, .participatesInCycle]
    print("[Settings][Init 18] Window collection behavior assigned")
    window.setFrameAutosaveName("CoveSettingsWindow")
    print("[Settings][Init 19] Window frame autosave name assigned")

    print("[Settings][Init 20] Calling NSWindowController.init(window:)")
    super.init(window: window)
    print("[Settings][Init 21] NSWindowController.init(window:) returned")
    window.delegate = self
    print("[Settings][Init 22] Window delegate assigned")
    shouldCascadeWindows = false
    print("[Settings][Init 23] Window cascading disabled")
    print("[Settings][Init 24] SettingsWindowController.init() completed:", [
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
    printLayoutDiagnostics(window)
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

  func presentChatPreview() {
    let controller: ChatWindowController
    if let existingController = chatWindowController {
      controller = existingController
    } else {
      controller = ChatWindowController()
      chatWindowController = controller
    }
    controller.present()
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

  private func printLayoutDiagnostics(_ window: NSWindow) {
    if let contentView = window.contentView {
      print(
        "[Settings][Layout] window.contentView.fittingSize:",
        NSStringFromSize(contentView.fittingSize)
      )
      print(
        "[Settings][Layout] window.contentView.intrinsicContentSize:",
        NSStringFromSize(contentView.intrinsicContentSize)
      )
    } else {
      print("[Settings][Layout] window.contentView.fittingSize: unavailable")
      print("[Settings][Layout] window.contentView.intrinsicContentSize: unavailable")
    }

    if let containerViewController = window.contentViewController as? SettingsContainerViewController {
      containerViewController.printLayoutDiagnostics()
    } else {
      print("[Settings][Layout] SettingsContainerViewController: unavailable")
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

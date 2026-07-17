import AppKit

/// Temporary host for testing the chat interface without changing Cove's
/// existing notch or Settings experiences.
final class ChatWindowController: NSWindowController {
  init() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 680, height: 560),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false
    )
    window.title = "Chat (Preview)"
    window.contentViewController = ChatViewController()
    window.minSize = NSSize(width: 420, height: 360)
    window.isReleasedWhenClosed = false

    super.init(window: window)
    shouldCascadeWindows = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func present() {
    guard let window else { return }
    window.center()
    NSApp.activate(ignoringOtherApps: true)
    showWindow(nil)
    window.makeKeyAndOrderFront(nil)
  }
}

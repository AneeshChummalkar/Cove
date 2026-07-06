import AppKit

private let panelWidth: CGFloat = 320
private let panelHeight: CGFloat = 54
private let topInset: CGFloat = 6
private let settingsButtonSize: CGFloat = 28

final class NotchPanel: NSPanel {
  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }
}

final class CapsuleView: NSView {
  let settingsButton = NSButton()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    buildView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    buildView()
  }

  private func buildView() {
    wantsLayer = true
    layer?.cornerRadius = 22
    layer?.cornerCurve = .continuous
    layer?.backgroundColor = NSColor.black.withAlphaComponent(0.86).cgColor
    layer?.borderWidth = 1
    layer?.borderColor = NSColor.white.withAlphaComponent(0.12).cgColor
    layer?.masksToBounds = true

    let label = NSTextField(labelWithString: "● Cove")
    label.translatesAutoresizingMaskIntoConstraints = false
    label.alignment = .center
    label.font = .systemFont(ofSize: 17, weight: .semibold)
    label.textColor = .white

    settingsButton.translatesAutoresizingMaskIntoConstraints = false
    settingsButton.isBordered = false
    settingsButton.bezelStyle = .regularSquare
    settingsButton.image = NSImage(
      systemSymbolName: "gearshape.fill",
      accessibilityDescription: "Settings"
    )
    settingsButton.imagePosition = .imageOnly
    settingsButton.contentTintColor = NSColor.white.withAlphaComponent(0.86)
    settingsButton.target = self
    settingsButton.action = #selector(settingsPressed)
    settingsButton.wantsLayer = true
    settingsButton.layer?.cornerRadius = settingsButtonSize / 2
    settingsButton.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.10).cgColor

    addSubview(label)
    addSubview(settingsButton)

    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.centerYAnchor.constraint(equalTo: centerYAnchor),

      settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      settingsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
      settingsButton.widthAnchor.constraint(equalToConstant: settingsButtonSize),
      settingsButton.heightAnchor.constraint(equalToConstant: settingsButtonSize)
    ])
  }

  @objc private func settingsPressed() {
    print("Settings button pressed")
  }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  private var panel: NotchPanel?
  private var capsuleView: CapsuleView?
  private var mouseTimer: Timer?

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    createNotchPanel()
  }

  func applicationWillTerminate(_ notification: Notification) {
    mouseTimer?.invalidate()
  }

  private func createNotchPanel() {
    guard let screen = primaryScreen() else {
      NSApp.terminate(nil)
      return
    }

    let screenFrame = screen.frame
    let originX = screenFrame.midX - panelWidth / 2
    let originY = screenFrame.maxY - panelHeight - topInset
    let frame = NSRect(x: originX, y: originY, width: panelWidth, height: panelHeight)

    let panel = NotchPanel(
      contentRect: frame,
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    let capsuleView = CapsuleView(frame: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight))

    panel.contentView = capsuleView
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = false
    panel.isMovable = false
    panel.isMovableByWindowBackground = false
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false
    panel.worksWhenModal = true
    panel.level = .screenSaver
    panel.collectionBehavior = [
      .canJoinAllSpaces,
      .fullScreenAuxiliary,
      .stationary,
      .ignoresCycle
    ]
    panel.titleVisibility = .hidden
    panel.titlebarAppearsTransparent = true
    panel.ignoresMouseEvents = true

    [
      NSWindow.ButtonType.closeButton,
      .miniaturizeButton,
      .zoomButton
    ].forEach { buttonType in
      panel.standardWindowButton(buttonType)?.isHidden = true
    }

    self.panel = panel
    self.capsuleView = capsuleView

    panel.orderFrontRegardless()
    startSettingsMouseGate()
  }

  private func primaryScreen() -> NSScreen? {
    NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.main
  }

  private func startSettingsMouseGate() {
    mouseTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
      guard
        let panel = self?.panel,
        let capsuleView = self?.capsuleView
      else {
        return
      }

      let mouseLocation = NSEvent.mouseLocation
      let settingsFrame = capsuleView.settingsButton.convert(
        capsuleView.settingsButton.bounds,
        to: nil
      )
      let settingsFrameOnScreen = panel.convertToScreen(settingsFrame)
      let isOverSettings = settingsFrameOnScreen.contains(mouseLocation)

      if panel.ignoresMouseEvents == isOverSettings {
        panel.ignoresMouseEvents = !isOverSettings
      }
    }
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
app.run()

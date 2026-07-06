import AppKit
import QuartzCore

private let panelWidth: CGFloat = 320
private let panelHeight: CGFloat = 54
private let topInset: CGFloat = 6
private let inactiveAlpha: CGFloat = 0.72
private let activeAlpha: CGFloat = 1.0
private let settingsButtonSize: CGFloat = 28

final class NotchPanel: NSPanel {
  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }
}

private struct NotchMetrics {
  let centerX: CGFloat
  let safeTopInset: CGFloat
  let topSafeBottomY: CGFloat
  let notchWidth: CGFloat
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
  private var workspaceObserver: NSObjectProtocol?
  private var screenObserver: NSObjectProtocol?

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    createNotchPanel()
    observeActiveApplicationChanges()
    observeScreenChanges()
  }

  func applicationWillTerminate(_ notification: Notification) {
    mouseTimer?.invalidate()

    if let workspaceObserver {
      NSWorkspace.shared.notificationCenter.removeObserver(workspaceObserver)
    }

    if let screenObserver {
      NotificationCenter.default.removeObserver(screenObserver)
    }
  }

  private func createNotchPanel() {
    guard let screen = primaryScreen() else {
      NSApp.terminate(nil)
      return
    }

    let metrics = notchMetrics(for: screen)
    let originX = metrics.centerX - panelWidth / 2
    let originY = metrics.topSafeBottomY - panelHeight - topInset
    let frame = NSRect(x: originX, y: originY, width: panelWidth, height: panelHeight)

    let panel = NotchPanel(
      contentRect: frame,
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    let capsuleView = CapsuleView(frame: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight))

    print("Cove notch metrics:", [
      "centerX": metrics.centerX,
      "safeTopInset": metrics.safeTopInset,
      "topSafeBottomY": metrics.topSafeBottomY,
      "notchWidth": metrics.notchWidth
    ])

    panel.contentView = capsuleView
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = false
    panel.isMovable = false
    panel.isMovableByWindowBackground = false
    panel.isFloatingPanel = true
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false
    panel.worksWhenModal = true
    panel.becomesKeyOnlyIfNeeded = true
    panel.acceptsMouseMovedEvents = true
    panel.animationBehavior = .none
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
    panel.alphaValue = activeAlpha

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
    updatePanelTransparency(for: NSWorkspace.shared.frontmostApplication)
  }

  private func primaryScreen() -> NSScreen? {
    NSScreen.screens.first ?? NSScreen.main
  }

  private func notchMetrics(for screen: NSScreen) -> NotchMetrics {
    let frame = screen.frame
    let visibleFrame = screen.visibleFrame
    let safeTopInset = screen.safeAreaInsets.top
    let leftAuxiliaryArea = screen.auxiliaryTopLeftArea
    let rightAuxiliaryArea = screen.auxiliaryTopRightArea
    let hasNotchGap = !leftAuxiliaryArea.isEmpty &&
      !rightAuxiliaryArea.isEmpty &&
      rightAuxiliaryArea.minX > leftAuxiliaryArea.maxX

    if hasNotchGap {
      let notchMinX = leftAuxiliaryArea.maxX
      let notchMaxX = rightAuxiliaryArea.minX
      let notchWidth = notchMaxX - notchMinX
      let topSafeBottomY = min(leftAuxiliaryArea.minY, rightAuxiliaryArea.minY)

      return NotchMetrics(
        centerX: notchMinX + notchWidth / 2,
        safeTopInset: safeTopInset,
        topSafeBottomY: topSafeBottomY,
        notchWidth: notchWidth
      )
    }

    let topSafeBottomY: CGFloat
    if safeTopInset > 0 {
      topSafeBottomY = frame.maxY - safeTopInset
    } else {
      topSafeBottomY = visibleFrame.maxY
    }

    return NotchMetrics(
      centerX: frame.midX,
      safeTopInset: safeTopInset,
      topSafeBottomY: topSafeBottomY,
      notchWidth: 0
    )
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

      if isOverSettings {
        self?.setPanelAlpha(activeAlpha)
      } else {
        self?.updatePanelTransparency(for: NSWorkspace.shared.frontmostApplication)
      }
    }
  }

  private func observeActiveApplicationChanges() {
    workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
      self?.updatePanelTransparency(for: app)
    }
  }

  private func observeScreenChanges() {
    screenObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.repositionPanel()
    }
  }

  private func updatePanelTransparency(for activeApplication: NSRunningApplication?) {
    let isCoveProcess = activeApplication?.processIdentifier == ProcessInfo.processInfo.processIdentifier
    let isCoveBundle = activeApplication?.bundleIdentifier == Bundle.main.bundleIdentifier
    let isCoveActive = isCoveProcess || isCoveBundle
    setPanelAlpha(isCoveActive ? activeAlpha : inactiveAlpha)
  }

  private func repositionPanel() {
    guard
      let panel,
      let screen = primaryScreen()
    else {
      return
    }

    let metrics = notchMetrics(for: screen)
    let frame = NSRect(
      x: metrics.centerX - panelWidth / 2,
      y: metrics.topSafeBottomY - panelHeight - topInset,
      width: panelWidth,
      height: panelHeight
    )

    panel.setFrame(frame, display: true, animate: false)
  }

  private func setPanelAlpha(_ alpha: CGFloat) {
    guard let panel, panel.alphaValue != alpha else {
      return
    }

    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.18
      context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      panel.animator().alphaValue = alpha
    }
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
app.run()

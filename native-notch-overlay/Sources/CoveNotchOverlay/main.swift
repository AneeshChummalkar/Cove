import AppKit
import QuartzCore

private let compactPanelHeight: CGFloat = 44
private let expandedPanelWidth: CGFloat = 424
private let expandedPanelHeight: CGFloat = 74
private let minimumCompactPanelWidth: CGFloat = 188
private let notchHorizontalPadding: CGFloat = 34
private let minimumNotchAttachmentWidth: CGFloat = 112
private let notchAttachmentHeight: CGFloat = 17
private let hoverSlop: CGFloat = 18
private let inactiveAlpha: CGFloat = 0.65
private let activeAlpha: CGFloat = 1.0
private let settingsButtonSize: CGFloat = 30
private let springInterval: TimeInterval = 1.0 / 120.0
private let springResponse: CGFloat = 0.34
private let springDampingRatio: CGFloat = 0.84
private let springSettleDistance: CGFloat = 0.45
private let springSettleVelocity: CGFloat = 0.45

enum OverlayState: String {
  case compact
  case expanded
}

final class NotchPanel: NSPanel {
  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }
  override var acceptsFirstResponder: Bool { false }

  override func performDrag(with event: NSEvent) {}

  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
  }
}

private struct NotchMetrics {
  let centerX: CGFloat
  let safeTopInset: CGFloat
  let topSafeBottomY: CGFloat
  let notchWidth: CGFloat
  let notchHeight: CGFloat
  let screenFrame: NSRect
  let visibleFrame: NSRect
  let auxiliaryTopLeftArea: NSRect
  let auxiliaryTopRightArea: NSRect
  let hasHardwareNotch: Bool
}

private struct SpringFrame {
  var x: CGFloat
  var topY: CGFloat
  var width: CGFloat
  var height: CGFloat

  init(_ rect: NSRect) {
    x = rect.origin.x
    topY = rect.maxY
    width = rect.width
    height = rect.height
  }

  var rect: NSRect {
    NSRect(x: x, y: topY - height, width: width, height: height)
  }
}

final class CapsuleView: NSView {
  let settingsButton = NSButton()
  var onSettingsPressed: ((NSButton) -> Void)?

  private let visualEffectView = NSVisualEffectView()
  private let notchAttachmentView = NSView()
  private let tintView = NSView()
  private let compactTitle = NSTextField(labelWithString: "● Cove")
  private let expandedTitle = NSTextField(labelWithString: "Cove")
  private let expandedSubtitle = NSTextField(labelWithString: "Ready near the notch")
  private let statusPill = NSTextField(labelWithString: "ready")
  private var notchAttachmentWidthConstraint: NSLayoutConstraint?

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
    layer?.cornerRadius = compactPanelHeight / 2
    layer?.cornerCurve = .continuous
    layer?.masksToBounds = true

    visualEffectView.translatesAutoresizingMaskIntoConstraints = false
    visualEffectView.material = .underWindowBackground
    visualEffectView.blendingMode = .behindWindow
    visualEffectView.state = .active
    visualEffectView.wantsLayer = true
    visualEffectView.layer?.cornerRadius = compactPanelHeight / 2
    visualEffectView.layer?.cornerCurve = .continuous
    visualEffectView.layer?.masksToBounds = true

    notchAttachmentView.translatesAutoresizingMaskIntoConstraints = false
    notchAttachmentView.alphaValue = 0
    notchAttachmentView.wantsLayer = true
    notchAttachmentView.layer?.cornerRadius = notchAttachmentHeight / 2
    notchAttachmentView.layer?.cornerCurve = .continuous
    notchAttachmentView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.10).cgColor
    notchAttachmentView.layer?.masksToBounds = true

    tintView.translatesAutoresizingMaskIntoConstraints = false
    tintView.wantsLayer = true
    tintView.layer?.cornerRadius = compactPanelHeight / 2
    tintView.layer?.cornerCurve = .continuous
    tintView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.10).cgColor
    tintView.layer?.borderWidth = 1
    tintView.layer?.borderColor = NSColor.white.withAlphaComponent(0.16).cgColor
    tintView.layer?.masksToBounds = true

    compactTitle.translatesAutoresizingMaskIntoConstraints = false
    compactTitle.alignment = .center
    compactTitle.font = .systemFont(ofSize: 15, weight: .semibold)
    compactTitle.textColor = .white
    compactTitle.shadow = textShadow()

    expandedTitle.translatesAutoresizingMaskIntoConstraints = false
    expandedTitle.font = .systemFont(ofSize: 14, weight: .semibold)
    expandedTitle.textColor = .white
    expandedTitle.alphaValue = 0
    expandedTitle.shadow = textShadow()

    expandedSubtitle.translatesAutoresizingMaskIntoConstraints = false
    expandedSubtitle.font = .systemFont(ofSize: 11.5, weight: .medium)
    expandedSubtitle.textColor = NSColor.white.withAlphaComponent(0.72)
    expandedSubtitle.alphaValue = 0
    expandedSubtitle.shadow = textShadow()

    statusPill.translatesAutoresizingMaskIntoConstraints = false
    statusPill.alignment = .center
    statusPill.font = .monospacedDigitSystemFont(ofSize: 10.5, weight: .semibold)
    statusPill.textColor = NSColor.white.withAlphaComponent(0.78)
    statusPill.wantsLayer = true
    statusPill.layer?.cornerRadius = 11
    statusPill.layer?.cornerCurve = .continuous
    statusPill.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.10).cgColor
    statusPill.layer?.borderWidth = 1
    statusPill.layer?.borderColor = NSColor.white.withAlphaComponent(0.13).cgColor

    settingsButton.translatesAutoresizingMaskIntoConstraints = false
    settingsButton.isBordered = false
    settingsButton.bezelStyle = .regularSquare
    settingsButton.image = NSImage(
      systemSymbolName: "gearshape.fill",
      accessibilityDescription: "Settings"
    )
    settingsButton.imagePosition = .imageOnly
    settingsButton.contentTintColor = NSColor.white.withAlphaComponent(0.82)
    settingsButton.target = self
    settingsButton.action = #selector(settingsPressed)
    settingsButton.wantsLayer = true
    settingsButton.layer?.cornerRadius = settingsButtonSize / 2
    settingsButton.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.08).cgColor

    addSubview(visualEffectView)
    addSubview(notchAttachmentView)
    addSubview(tintView)
    addSubview(compactTitle)
    addSubview(expandedTitle)
    addSubview(expandedSubtitle)
    addSubview(statusPill)
    addSubview(settingsButton)

    NSLayoutConstraint.activate([
      visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
      visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
      visualEffectView.topAnchor.constraint(equalTo: topAnchor),
      visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

      notchAttachmentView.centerXAnchor.constraint(equalTo: centerXAnchor),
      notchAttachmentView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
      notchAttachmentView.heightAnchor.constraint(equalToConstant: notchAttachmentHeight),

      tintView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tintView.trailingAnchor.constraint(equalTo: trailingAnchor),
      tintView.topAnchor.constraint(equalTo: topAnchor),
      tintView.bottomAnchor.constraint(equalTo: bottomAnchor),

      compactTitle.centerXAnchor.constraint(equalTo: centerXAnchor),
      compactTitle.centerYAnchor.constraint(equalTo: centerYAnchor),

      expandedTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
      expandedTitle.topAnchor.constraint(equalTo: topAnchor, constant: 17),

      expandedSubtitle.leadingAnchor.constraint(equalTo: expandedTitle.leadingAnchor),
      expandedSubtitle.topAnchor.constraint(equalTo: expandedTitle.bottomAnchor, constant: 4),

      statusPill.leadingAnchor.constraint(equalTo: expandedTitle.trailingAnchor, constant: 10),
      statusPill.centerYAnchor.constraint(equalTo: expandedTitle.centerYAnchor),
      statusPill.widthAnchor.constraint(equalToConstant: 54),
      statusPill.heightAnchor.constraint(equalToConstant: 22),

      settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      settingsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
      settingsButton.widthAnchor.constraint(equalToConstant: settingsButtonSize),
      settingsButton.heightAnchor.constraint(equalToConstant: settingsButtonSize)
    ])

    let attachmentWidth = notchAttachmentView.widthAnchor.constraint(
      equalToConstant: minimumNotchAttachmentWidth
    )
    attachmentWidth.isActive = true
    notchAttachmentWidthConstraint = attachmentWidth
  }

  private func textShadow() -> NSShadow {
    let shadow = NSShadow()
    shadow.shadowBlurRadius = 5
    shadow.shadowOffset = NSSize(width: 0, height: -1)
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
    return shadow
  }

  @objc private func settingsPressed() {
    print("Settings button pressed")
    let handler = onSettingsPressed
    print("[Settings] CapsuleView forwarding gear action:", [
      "capsule": String(describing: ObjectIdentifier(self)),
      "handlerInstalled": handler != nil
    ])
    handler?(settingsButton)
  }

  func setNotchAttachment(width: CGFloat, visible: Bool, animated: Bool) {
    notchAttachmentWidthConstraint?.constant = max(width, minimumNotchAttachmentWidth)

    let targetAlpha: CGFloat = visible ? 1 : 0
    guard notchAttachmentView.alphaValue != targetAlpha else {
      return
    }

    if animated {
      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.22
        context.timingFunction = CAMediaTimingFunction(name: .easeOut)
        notchAttachmentView.animator().alphaValue = targetAlpha
      }
    } else {
      notchAttachmentView.alphaValue = targetAlpha
    }
  }

  func setState(_ state: OverlayState, animated: Bool) {
    let isExpanded = state == .expanded
    let radius = isExpanded ? CGFloat(29) : compactPanelHeight / 2
    let compactAlpha: CGFloat = isExpanded ? 0 : 1
    let expandedAlpha: CGFloat = isExpanded ? 1 : 0
    let tintColor = NSColor.black
      .withAlphaComponent(isExpanded ? 0.08 : 0.10)
      .cgColor

    setRoundedGlass(radius: radius, tintColor: tintColor, animated: animated)

    if animated {
      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.24
        context.timingFunction = CAMediaTimingFunction(name: .easeOut)
        compactTitle.animator().alphaValue = compactAlpha
        expandedTitle.animator().alphaValue = expandedAlpha
        expandedSubtitle.animator().alphaValue = expandedAlpha
        statusPill.animator().alphaValue = expandedAlpha
      }
    } else {
      compactTitle.alphaValue = compactAlpha
      expandedTitle.alphaValue = expandedAlpha
      expandedSubtitle.alphaValue = expandedAlpha
      statusPill.alphaValue = expandedAlpha
    }
  }

  private func setRoundedGlass(radius: CGFloat, tintColor: CGColor, animated: Bool) {
    guard animated else {
      layer?.cornerRadius = radius
      visualEffectView.layer?.cornerRadius = radius
      tintView.layer?.cornerRadius = radius
      tintView.layer?.backgroundColor = tintColor
      return
    }

    spring(layer: layer, keyPath: "cornerRadius", toValue: radius)
    spring(layer: visualEffectView.layer, keyPath: "cornerRadius", toValue: radius)
    spring(layer: tintView.layer, keyPath: "cornerRadius", toValue: radius)
    spring(layer: tintView.layer, keyPath: "backgroundColor", toValue: tintColor)
  }

  private func spring(layer: CALayer?, keyPath: String, toValue: Any) {
    guard let layer else {
      return
    }

    let animation = CASpringAnimation(keyPath: keyPath)
    animation.mass = 1
    animation.stiffness = 430
    animation.damping = 34
    animation.initialVelocity = 0
    animation.fromValue = layer.presentation()?.value(forKeyPath: keyPath)
      ?? layer.value(forKeyPath: keyPath)
    animation.toValue = toValue
    animation.duration = min(animation.settlingDuration, 0.56)

    CATransaction.begin()
    CATransaction.setDisableActions(true)
    layer.setValue(toValue, forKeyPath: keyPath)
    CATransaction.commit()

    layer.add(animation, forKey: keyPath)
  }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  private var panel: NotchPanel?
  private var capsuleView: CapsuleView?
  private var mouseTimer: Timer?
  private var animationTimer: Timer?
  private var workspaceObserver: NSObjectProtocol?
  private var screenObserver: NSObjectProtocol?
  private var settingsWindowController: SettingsWindowController?
  private var overlayState: OverlayState = .compact
  private var isHovering = false
  private var lastLoggedNotchDescription = ""
  private var springFrame: SpringFrame?
  private var springVelocity = SpringFrame(NSRect.zero)

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    SettingsStore.shared.applyPersistedAppearance()
    createNotchPanel()
    observeActiveApplicationChanges()
    observeScreenChanges()
  }

  func applicationWillTerminate(_ notification: Notification) {
    mouseTimer?.invalidate()
    animationTimer?.invalidate()

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
    logNotchMetrics(metrics)

    let frame = panelFrame(for: overlayState, metrics: metrics)

    let panel = NotchPanel(
      contentRect: frame,
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    let capsuleView = CapsuleView(frame: NSRect(origin: .zero, size: frame.size))
    capsuleView.autoresizingMask = [.width, .height]
    capsuleView.setState(overlayState, animated: false)
    capsuleView.setNotchAttachment(
      width: notchAttachmentWidth(for: metrics),
      visible: metrics.hasHardwareNotch,
      animated: false
    )
    capsuleView.onSettingsPressed = { [weak self] _ in
      guard let self else {
        print("[Settings] Gear handler could not continue: AppDelegate was released")
        return
      }
      print("[Settings] AppDelegate gear handler entered:", String(describing: ObjectIdentifier(self)))
      self.showSettingsWindow()
    }
    print("[Settings] Gear handler installed on CapsuleView:", [
      "appDelegate": String(describing: ObjectIdentifier(self)),
      "capsule": String(describing: ObjectIdentifier(capsuleView))
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
    springFrame = SpringFrame(frame)

    panel.orderFrontRegardless()
    logPanelFrame(frame, reason: "initial")
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

    if let leftAuxiliaryArea = screen.auxiliaryTopLeftArea,
      let rightAuxiliaryArea = screen.auxiliaryTopRightArea,
      !leftAuxiliaryArea.isEmpty,
      !rightAuxiliaryArea.isEmpty,
      rightAuxiliaryArea.minX > leftAuxiliaryArea.maxX
    {
      let notchMinX = leftAuxiliaryArea.maxX
      let notchMaxX = rightAuxiliaryArea.minX
      let notchWidth = notchMaxX - notchMinX
      let topSafeBottomY = min(leftAuxiliaryArea.minY, rightAuxiliaryArea.minY)

      return NotchMetrics(
        centerX: notchMinX + notchWidth / 2,
        safeTopInset: safeTopInset,
        topSafeBottomY: topSafeBottomY,
        notchWidth: notchWidth,
        notchHeight: frame.maxY - topSafeBottomY,
        screenFrame: frame,
        visibleFrame: visibleFrame,
        auxiliaryTopLeftArea: leftAuxiliaryArea,
        auxiliaryTopRightArea: rightAuxiliaryArea,
        hasHardwareNotch: true
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
      notchWidth: 0,
      notchHeight: max(0, frame.maxY - topSafeBottomY),
      screenFrame: frame,
      visibleFrame: visibleFrame,
      auxiliaryTopLeftArea: screen.auxiliaryTopLeftArea ?? .zero,
      auxiliaryTopRightArea: screen.auxiliaryTopRightArea ?? .zero,
      hasHardwareNotch: false
    )
  }

  private func panelSize(for state: OverlayState, metrics: NotchMetrics) -> NSSize {
    switch state {
    case .compact:
      return NSSize(
        width: max(metrics.notchWidth + notchHorizontalPadding, minimumCompactPanelWidth),
        height: compactPanelHeight
      )
    case .expanded:
      let availableWidth = metrics.screenFrame.width - 32
      return NSSize(width: min(expandedPanelWidth, availableWidth), height: expandedPanelHeight)
    }
  }

  private func panelFrame(for state: OverlayState, metrics: NotchMetrics) -> NSRect {
    let size = panelSize(for: state, metrics: metrics)
    let topEdge = metrics.topSafeBottomY + notchAttachOverlap(for: metrics)

    return NSRect(
      x: metrics.centerX - size.width / 2,
      y: topEdge - size.height,
      width: size.width,
      height: size.height
    )
  }

  private func notchAttachOverlap(for metrics: NotchMetrics) -> CGFloat {
    if metrics.hasHardwareNotch {
      return min(max(metrics.notchHeight * 0.38, 16), 24)
    }

    if metrics.safeTopInset > 0 {
      return min(max(metrics.safeTopInset * 0.24, 8), 14)
    }

    return 7
  }

  private func notchAttachmentWidth(for metrics: NotchMetrics) -> CGFloat {
    guard metrics.hasHardwareNotch else {
      return minimumNotchAttachmentWidth
    }

    return max(metrics.notchWidth + 18, minimumNotchAttachmentWidth)
  }

  private func startSettingsMouseGate() {
    mouseTimer?.invalidate()

    let timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
      guard
        let self,
        let panel = self.panel,
        let capsuleView = self.capsuleView
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
      let hoverFrame = panel.frame.insetBy(dx: -hoverSlop, dy: -hoverSlop)
      let shouldPreserveCompactSettingsClick = overlayState == .compact && isOverSettings
      let nextHoverState = (
        hoverFrame.contains(mouseLocation) &&
          !shouldPreserveCompactSettingsClick
      ) || (settingsWindowController?.window?.isVisible ?? false)

      if isHovering != nextHoverState {
        isHovering = nextHoverState
        print("Cove hover state:", nextHoverState ? "hovering" : "not hovering")
        setOverlayState(nextHoverState ? .expanded : .compact)
      }

      if panel.ignoresMouseEvents == isOverSettings {
        panel.ignoresMouseEvents = !isOverSettings
        print("Cove mouse passthrough:", panel.ignoresMouseEvents ? "enabled" : "settings button active")
      }

      if isOverSettings {
        setPanelAlpha(activeAlpha)
      } else {
        updatePanelTransparency(for: NSWorkspace.shared.frontmostApplication)
      }
    }

    mouseTimer = timer
    RunLoop.main.add(timer, forMode: .common)
  }

  private func observeActiveApplicationChanges() {
    workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
      print("Cove active application changed:", [
        "name": app?.localizedName ?? "unknown",
        "bundleIdentifier": app?.bundleIdentifier ?? "unknown",
        "pid": app?.processIdentifier ?? -1
      ])
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
    let shouldStayBright = isCoveActive || isHovering || (settingsWindowController?.window?.isVisible ?? false)
    setPanelAlpha(shouldStayBright ? activeAlpha : inactiveAlpha)
  }

  private func repositionPanel() {
    guard
      let panel,
      let screen = primaryScreen()
    else {
      return
    }

    let metrics = notchMetrics(for: screen)
    logNotchMetrics(metrics)
    let frame = panelFrame(for: overlayState, metrics: metrics)

    capsuleView?.setNotchAttachment(
      width: notchAttachmentWidth(for: metrics),
      visible: metrics.hasHardwareNotch,
      animated: true
    )
    panel.setFrame(frame, display: true, animate: false)
    springFrame = SpringFrame(frame)
    logPanelFrame(frame, reason: "screen changed")
  }

  private func setPanelAlpha(_ alpha: CGFloat) {
    guard let panel, panel.alphaValue != alpha else {
      return
    }

    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.24
      context.timingFunction = CAMediaTimingFunction(name: .easeOut)
      panel.animator().alphaValue = alpha
    }
  }

  private func setOverlayState(_ nextState: OverlayState) {
    guard overlayState != nextState else {
      return
    }

    overlayState = nextState
    print("Cove expansion state:", nextState.rawValue)
    capsuleView?.setState(nextState, animated: true)

    guard let screen = primaryScreen() else {
      return
    }

    let metrics = notchMetrics(for: screen)
    let targetFrame = panelFrame(for: nextState, metrics: metrics)
    capsuleView?.setNotchAttachment(
      width: notchAttachmentWidth(for: metrics),
      visible: metrics.hasHardwareNotch,
      animated: true
    )
    animatePanel(to: targetFrame)
  }

  private func animatePanel(to targetFrame: NSRect) {
    guard let panel else {
      return
    }

    animationTimer?.invalidate()

    if springFrame == nil {
      springFrame = SpringFrame(panel.frame)
    }

    let timer = Timer(timeInterval: springInterval, repeats: true) { [weak self] timer in
      guard
        let self,
        let panel = self.panel,
        var frame = self.springFrame
      else {
        timer.invalidate()
        return
      }

      let target = SpringFrame(targetFrame)
      let step = CGFloat(springInterval)

      Self.spring(&frame.x, velocity: &self.springVelocity.x, target: target.x, step: step)
      Self.spring(&frame.topY, velocity: &self.springVelocity.topY, target: target.topY, step: step)
      Self.spring(&frame.width, velocity: &self.springVelocity.width, target: target.width, step: step)
      Self.spring(&frame.height, velocity: &self.springVelocity.height, target: target.height, step: step)

      self.springFrame = frame
      panel.setFrame(frame.rect, display: true, animate: false)

      let remainingDistance =
        abs(frame.x - target.x) +
        abs(frame.topY - target.topY) +
        abs(frame.width - target.width) +
        abs(frame.height - target.height)
      let remainingVelocity =
        abs(self.springVelocity.x) +
        abs(self.springVelocity.topY) +
        abs(self.springVelocity.width) +
        abs(self.springVelocity.height)

      if remainingDistance < springSettleDistance && remainingVelocity < springSettleVelocity {
        panel.setFrame(targetFrame, display: true, animate: false)
        self.springFrame = target
        self.springVelocity = SpringFrame(NSRect.zero)
        self.logPanelFrame(targetFrame, reason: "spring settled")
        timer.invalidate()
      }
    }

    animationTimer = timer
    RunLoop.main.add(timer, forMode: .common)
  }

  private static func spring(
    _ value: inout CGFloat,
    velocity: inout CGFloat,
    target: CGFloat,
    step: CGFloat
  ) {
    let angularFrequency = 2 * CGFloat.pi / springResponse
    let stiffness = angularFrequency * angularFrequency
    let damping = 2 * springDampingRatio * angularFrequency
    let displacement = target - value
    let acceleration = stiffness * displacement - damping * velocity

    velocity += acceleration * step
    value += velocity * step
  }

  private func showSettingsWindow() {
    print("[Settings] showSettingsWindow() entered:", [
      "hasExistingController": settingsWindowController != nil,
      "appIsActive": NSApp.isActive,
      "appIsHidden": NSApp.isHidden
    ])
    setOverlayState(.expanded)
    setPanelAlpha(activeAlpha)

    let controller: SettingsWindowController
    if let existingController = settingsWindowController {
      controller = existingController
      print("[Settings] Reusing retained SettingsWindowController:", String(describing: ObjectIdentifier(controller)))
    } else {
      print("[Settings] Instantiating SettingsWindowController")
      controller = SettingsWindowController()
      settingsWindowController = controller
      print("[Settings] SettingsWindowController retained by AppDelegate:", [
        "controller": String(describing: ObjectIdentifier(controller)),
        "retained": settingsWindowController === controller
      ])
    }

    print("[Settings] Calling SettingsWindowController.present()")
    controller.present()
  }

  private func logNotchMetrics(_ metrics: NotchMetrics) {
    let description = [
      "centerX": metrics.centerX,
      "safeTopInset": metrics.safeTopInset,
      "topSafeBottomY": metrics.topSafeBottomY,
      "notchWidth": metrics.notchWidth,
      "notchHeight": metrics.notchHeight,
      "hasHardwareNotch": metrics.hasHardwareNotch,
      "screenFrame": NSStringFromRect(metrics.screenFrame),
      "visibleFrame": NSStringFromRect(metrics.visibleFrame),
      "auxiliaryTopLeftArea": NSStringFromRect(metrics.auxiliaryTopLeftArea),
      "auxiliaryTopRightArea": NSStringFromRect(metrics.auxiliaryTopRightArea)
    ] as [String: Any]
    let stringDescription = String(describing: description)

    guard stringDescription != lastLoggedNotchDescription else {
      return
    }

    lastLoggedNotchDescription = stringDescription
    print("Cove notch metrics:", description)
  }

  private func logPanelFrame(_ frame: NSRect, reason: String) {
    print("Cove panel position:", [
      "reason": reason,
      "state": overlayState.rawValue,
      "frame": NSStringFromRect(frame)
    ])
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
withExtendedLifetime(delegate) {
  print("[Settings] AppDelegate lifetime pinned for application run loop:", String(describing: ObjectIdentifier(delegate)))
  app.run()
}

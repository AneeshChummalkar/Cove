import AppKit
import CoreAudio
import QuartzCore

private let compactPanelHeight: CGFloat = 46
private let expandedPanelWidth: CGFloat = 438
private let responsePanelHeight: CGFloat = 360
private let minimumCompactPanelWidth: CGFloat = 188
private let notchHorizontalPadding: CGFloat = 34
private let notchAttachOverlap: CGFloat = 11
private let hoverSlop: CGFloat = 18
private let inactiveAlpha: CGFloat = 0.78
private let activeAlpha: CGFloat = 0.96
private let settingsButtonSize: CGFloat = 30
private let springInterval: TimeInterval = 1.0 / 60.0
private let springStiffness: CGFloat = 520
private let springDamping: CGFloat = 46

enum OverlayState: String {
  case compact
  case expanded
  case response
}

final class NotchPanel: NSPanel {
  var onEscapePressed: (() -> Void)?
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }
  override var acceptsFirstResponder: Bool { true }

  override func performDrag(with event: NSEvent) {}

  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
  }

  override func keyDown(with event: NSEvent) {
    if event.keyCode == 53 {
      onEscapePressed?()
    } else {
      super.keyDown(with: event)
    }
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
  var y: CGFloat
  var width: CGFloat
  var height: CGFloat

  init(_ rect: NSRect) {
    x = rect.origin.x
    y = rect.origin.y
    width = rect.width
    height = rect.height
  }

  var rect: NSRect {
    NSRect(x: x, y: y, width: width, height: height)
  }
}

final class CapsuleView: NSView, NSTextViewDelegate {
  let settingsButton = NSButton()
  var onSettingsPressed: ((NSButton) -> Void)?
  var onPromptSubmitted: ((String) -> Void)?
  var onCollapseRequested: (() -> Void)?

  private let visualEffectView = NSVisualEffectView()
  private let tintView = NSView()
  private let responseSurface = NSVisualEffectView()
  private let compactTitle = NSTextField(labelWithString: "● Cove")
  private let expandedTitle = NSTextField(labelWithString: "Cove")
  private let expandedSubtitle = NSTextField(labelWithString: "Ready near the notch")
  private let statusPill = NSTextField(labelWithString: "idle")
  private let inputTextView = NSTextView()
  private let inputScrollView = NSScrollView()
  private let inputPlaceholderLabel = NSTextField(labelWithString: "Ask Cove...")
  private let promptLabel = NSTextField(wrappingLabelWithString: "")
  private let responseDivider = NSBox()
  private let responseTextView = NSTextView()
  private let responseScrollView = NSScrollView()
  private var stateObserver: NSObjectProtocol?
  private var hoverTrackingArea: NSTrackingArea?
  private var overlayState: OverlayState = .compact

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    buildView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    buildView()
  }

  deinit {
    if let stateObserver {
      NotificationCenter.default.removeObserver(stateObserver)
    }
  }

  private func buildView() {
    wantsLayer = true
    layer?.masksToBounds = false

    visualEffectView.translatesAutoresizingMaskIntoConstraints = false
    visualEffectView.material = .hudWindow
    visualEffectView.blendingMode = .behindWindow
    visualEffectView.state = .active
    visualEffectView.wantsLayer = true
    visualEffectView.layer?.cornerRadius = compactPanelHeight / 2
    visualEffectView.layer?.cornerCurve = .continuous
    visualEffectView.layer?.masksToBounds = true

    tintView.translatesAutoresizingMaskIntoConstraints = false
    tintView.wantsLayer = true
    tintView.layer?.cornerRadius = compactPanelHeight / 2
    tintView.layer?.cornerCurve = .continuous
    tintView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.24).cgColor
    tintView.layer?.borderWidth = 1
    tintView.layer?.borderColor = NSColor.white.withAlphaComponent(0.18).cgColor
    tintView.layer?.masksToBounds = true

    responseSurface.translatesAutoresizingMaskIntoConstraints = false
    responseSurface.material = .hudWindow
    responseSurface.blendingMode = .behindWindow
    responseSurface.state = .active
    responseSurface.wantsLayer = true
    responseSurface.layer?.cornerRadius = compactPanelHeight / 2
    responseSurface.layer?.cornerCurve = .continuous
    responseSurface.layer?.masksToBounds = true
    responseSurface.isHidden = true

    compactTitle.translatesAutoresizingMaskIntoConstraints = false
    compactTitle.alignment = .center
    compactTitle.font = .systemFont(ofSize: 16, weight: .semibold)
    compactTitle.textColor = .white

    expandedTitle.translatesAutoresizingMaskIntoConstraints = false
    expandedTitle.font = .systemFont(ofSize: 15, weight: .semibold)
    expandedTitle.textColor = .white
    expandedTitle.alphaValue = 0

    expandedSubtitle.translatesAutoresizingMaskIntoConstraints = false
    expandedSubtitle.font = .systemFont(ofSize: 12, weight: .medium)
    expandedSubtitle.textColor = NSColor.white.withAlphaComponent(0.68)
    expandedSubtitle.alphaValue = 0

    statusPill.translatesAutoresizingMaskIntoConstraints = false
    statusPill.alignment = .center
    statusPill.font = .systemFont(ofSize: 11, weight: .semibold)
    statusPill.textColor = NSColor.white.withAlphaComponent(0.82)
    statusPill.wantsLayer = true
    statusPill.layer?.cornerRadius = 10
    statusPill.layer?.cornerCurve = .continuous
    statusPill.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.12).cgColor

    inputTextView.font = .systemFont(ofSize: 13, weight: .regular)
    inputTextView.textColor = .white
    inputTextView.insertionPointColor = .white
    inputTextView.drawsBackground = false
    inputTextView.isRichText = false
    inputTextView.allowsUndo = true
    inputTextView.textContainerInset = NSSize(width: 8, height: 7)
    inputTextView.delegate = self
    inputTextView.isHorizontallyResizable = false
    inputTextView.textContainer?.widthTracksTextView = true

    inputScrollView.translatesAutoresizingMaskIntoConstraints = false
    inputScrollView.drawsBackground = false
    inputScrollView.borderType = .noBorder
    inputScrollView.hasVerticalScroller = false
    inputScrollView.documentView = inputTextView
    inputScrollView.isHidden = true

    inputPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
    inputPlaceholderLabel.font = .systemFont(ofSize: 13, weight: .regular)
    inputPlaceholderLabel.textColor = NSColor.white.withAlphaComponent(0.52)
    inputPlaceholderLabel.isHidden = true

    promptLabel.translatesAutoresizingMaskIntoConstraints = false
    promptLabel.font = .systemFont(ofSize: 13, weight: .medium)
    promptLabel.textColor = .white
    promptLabel.isHidden = true

    responseDivider.translatesAutoresizingMaskIntoConstraints = false
    responseDivider.boxType = .separator
    responseDivider.isHidden = true

    responseTextView.font = .systemFont(ofSize: 13, weight: .regular)
    responseTextView.textColor = NSColor.white.withAlphaComponent(0.88)
    responseTextView.drawsBackground = false
    responseTextView.isEditable = false
    responseTextView.isSelectable = true
    responseTextView.isRichText = false
    responseTextView.textContainerInset = NSSize(width: 4, height: 6)
    responseTextView.isHorizontallyResizable = false
    responseTextView.isVerticallyResizable = true
    responseTextView.textContainer?.widthTracksTextView = true

    responseScrollView.translatesAutoresizingMaskIntoConstraints = false
    responseScrollView.drawsBackground = false
    responseScrollView.hasVerticalScroller = true
    responseScrollView.autohidesScrollers = true
    responseScrollView.borderType = .noBorder
    responseScrollView.documentView = responseTextView
    responseScrollView.isHidden = true

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

    addSubview(visualEffectView)
    addSubview(tintView)
    addSubview(responseSurface)
    addSubview(compactTitle)
    addSubview(expandedTitle)
    addSubview(expandedSubtitle)
    addSubview(statusPill)
    addSubview(inputScrollView)
    addSubview(inputPlaceholderLabel)
    responseSurface.addSubview(promptLabel)
    responseSurface.addSubview(responseDivider)
    responseSurface.addSubview(responseScrollView)
    addSubview(settingsButton)

    NSLayoutConstraint.activate([
      visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
      visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
      visualEffectView.topAnchor.constraint(equalTo: topAnchor),
      visualEffectView.heightAnchor.constraint(equalToConstant: compactPanelHeight),

      tintView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tintView.trailingAnchor.constraint(equalTo: trailingAnchor),
      tintView.topAnchor.constraint(equalTo: topAnchor),
      tintView.heightAnchor.constraint(equalToConstant: compactPanelHeight),

      responseSurface.leadingAnchor.constraint(equalTo: leadingAnchor),
      responseSurface.trailingAnchor.constraint(equalTo: trailingAnchor),
      responseSurface.topAnchor.constraint(equalTo: topAnchor, constant: compactPanelHeight),
      responseSurface.bottomAnchor.constraint(equalTo: bottomAnchor),

      compactTitle.centerXAnchor.constraint(equalTo: centerXAnchor),
      compactTitle.centerYAnchor.constraint(
        equalTo: topAnchor,
        constant: compactPanelHeight / 2
      ),

      expandedTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
      expandedTitle.centerYAnchor.constraint(
        equalTo: topAnchor,
        constant: compactPanelHeight / 2
      ),

      expandedSubtitle.leadingAnchor.constraint(equalTo: expandedTitle.leadingAnchor),
      expandedSubtitle.topAnchor.constraint(equalTo: expandedTitle.bottomAnchor, constant: 3),

      statusPill.leadingAnchor.constraint(equalTo: expandedTitle.trailingAnchor, constant: 12),
      statusPill.centerYAnchor.constraint(equalTo: expandedTitle.centerYAnchor),
      statusPill.widthAnchor.constraint(equalToConstant: 68),
      statusPill.heightAnchor.constraint(equalToConstant: 20),

      inputScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
      inputScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -54),
      inputScrollView.centerYAnchor.constraint(
        equalTo: topAnchor,
        constant: compactPanelHeight / 2
      ),
      inputScrollView.heightAnchor.constraint(equalToConstant: 38),

      inputPlaceholderLabel.leadingAnchor.constraint(equalTo: inputScrollView.leadingAnchor, constant: 10),
      inputPlaceholderLabel.centerYAnchor.constraint(equalTo: inputScrollView.centerYAnchor),

      promptLabel.leadingAnchor.constraint(equalTo: responseSurface.leadingAnchor, constant: 20),
      promptLabel.trailingAnchor.constraint(equalTo: responseSurface.trailingAnchor, constant: -20),
      promptLabel.topAnchor.constraint(equalTo: responseSurface.topAnchor),

      responseDivider.leadingAnchor.constraint(equalTo: promptLabel.leadingAnchor),
      responseDivider.trailingAnchor.constraint(equalTo: promptLabel.trailingAnchor),
      responseDivider.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 14),

      responseScrollView.leadingAnchor.constraint(equalTo: promptLabel.leadingAnchor),
      responseScrollView.trailingAnchor.constraint(equalTo: promptLabel.trailingAnchor),
      responseScrollView.topAnchor.constraint(equalTo: responseDivider.bottomAnchor, constant: 10),
      responseScrollView.bottomAnchor.constraint(equalTo: responseSurface.bottomAnchor, constant: -16),

      settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      settingsButton.centerYAnchor.constraint(
        equalTo: topAnchor,
        constant: compactPanelHeight / 2
      ),
      settingsButton.widthAnchor.constraint(equalToConstant: settingsButtonSize),
      settingsButton.heightAnchor.constraint(equalToConstant: settingsButtonSize)
    ])

    stateObserver = NotificationCenter.default.addObserver(
      forName: CoveStateManager.didChangeNotification,
      object: CoveStateManager.shared,
      queue: .main
    ) { [weak self] notification in
      guard let state = notification.userInfo?["state"] as? CoveState else { return }
      self?.updateInteractionState(state)
    }
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

  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    if let hoverTrackingArea {
      removeTrackingArea(hoverTrackingArea)
    }
    let trackingArea = NSTrackingArea(
      rect: bounds,
      options: [.activeAlways, .mouseEnteredAndExited],
      owner: self,
      userInfo: nil
    )
    addTrackingArea(trackingArea)
    hoverTrackingArea = trackingArea
  }

  override func mouseEntered(with event: NSEvent) {
    print("Cove notch tracking: mouse entered")
  }

  override func mouseExited(with event: NSEvent) {
    print("Cove notch tracking: mouse exited")
  }

  override func hitTest(_ point: NSPoint) -> NSView? {
    if settingsButton.frame.contains(point) {
      return settingsButton
    }
    return super.hitTest(point)
  }

  func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    guard commandSelector == #selector(NSResponder.insertNewline(_:)) else { return false }

    let prompt = textView.string.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !prompt.isEmpty else { return true }
    textView.isEditable = false
    onPromptSubmitted?(prompt)
    return true
  }

  func textDidChange(_ notification: Notification) {
    inputPlaceholderLabel.isHidden = !inputTextView.string.isEmpty
  }

  func setState(_ state: OverlayState, animated: Bool) {
    overlayState = state
    let isExpanded = state != .compact
    let showsInput = state == .expanded && responseScrollView.isHidden
    let radius = compactPanelHeight / 2
    let compactAlpha: CGFloat = isExpanded ? 0 : 1
    let titleAlpha: CGFloat = isExpanded && !showsInput ? 1 : 0
    let tintColor = NSColor.black
      .withAlphaComponent(isExpanded ? 0.20 : 0.24)
      .cgColor

    visualEffectView.layer?.cornerRadius = radius
    tintView.layer?.cornerRadius = radius
    tintView.layer?.backgroundColor = tintColor

    if animated {
      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.18
        context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        compactTitle.animator().alphaValue = compactAlpha
        expandedTitle.animator().alphaValue = titleAlpha
        expandedSubtitle.animator().alphaValue = 0
        statusPill.animator().alphaValue = 0
      }
    } else {
      compactTitle.alphaValue = compactAlpha
      expandedTitle.alphaValue = titleAlpha
      expandedSubtitle.alphaValue = 0
      statusPill.alphaValue = 0
    }

    updateInteractionState(CoveStateManager.shared.state)
  }

  func showResponse(_ response: String) {
    promptLabel.stringValue = inputTextView.string
    responseTextView.string = response
    inputScrollView.isHidden = true
    inputPlaceholderLabel.isHidden = true
    promptLabel.isHidden = false
    responseDivider.isHidden = false
    responseScrollView.isHidden = false
    responseSurface.isHidden = false
  }

  func resetInteraction() {
    inputTextView.string = ""
    inputTextView.isEditable = true
    inputScrollView.isHidden = true
    inputPlaceholderLabel.isHidden = true
    promptLabel.isHidden = true
    responseDivider.isHidden = true
    responseScrollView.isHidden = true
    responseTextView.string = ""
    responseSurface.isHidden = true
  }

  private func updateInteractionState(_ state: CoveState) {
    let showsInput = overlayState == .expanded && responseScrollView.isHidden
    if showsInput {
      inputScrollView.isHidden = false
      inputPlaceholderLabel.isHidden = !inputTextView.string.isEmpty
    } else if overlayState == .compact {
      inputScrollView.isHidden = true
      inputPlaceholderLabel.isHidden = true
    }
    if state == .thinking {
      expandedTitle.alphaValue = 0
      statusPill.alphaValue = 0
    }
    if state == .textMode {
      expandedTitle.alphaValue = 0
      statusPill.alphaValue = 0
      DispatchQueue.main.async { [weak self] in
        self?.window?.makeFirstResponder(self?.inputTextView)
      }
    }
  }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  private var panel: NotchPanel?
  private var capsuleView: CapsuleView?
  private var mouseTimer: Timer?
  private var animationTimer: Timer?
  private var workspaceObserver: NSObjectProtocol?
  private var screenObserver: NSObjectProtocol?
  private var localEventMonitor: Any?
  private var globalEventMonitor: Any?
  private var settingsWindowController: SettingsWindowController?
  private var overlayState: OverlayState = .compact
  private var isHovering = false
  private var lastLoggedNotchDescription = ""
  private var springFrame: SpringFrame?
  private var springVelocity = SpringFrame(NSRect.zero)
  private var defaultsToVoiceMode = false

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
    if let localEventMonitor {
      NSEvent.removeMonitor(localEventMonitor)
    }
    if let globalEventMonitor {
      NSEvent.removeMonitor(globalEventMonitor)
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
    capsuleView.onSettingsPressed = { [weak self] _ in
      guard let self else {
        print("[Settings] Gear handler could not continue: AppDelegate was released")
        return
      }
      print("[Settings] AppDelegate gear handler entered:", String(describing: ObjectIdentifier(self)))
      self.showSettingsWindow()
    }
    capsuleView.onPromptSubmitted = { [weak self] prompt in
      self?.sendNotchPrompt(prompt)
    }
    panel.onEscapePressed = { [weak self] in
      self?.collapseNotchInteraction()
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
    installOutsideClickMonitoring()
    configureDefaultNotchInteraction()
    updatePanelTransparency(for: NSWorkspace.shared.frontmostApplication)
  }

  private func primaryScreen() -> NSScreen? {
    NSScreen.screens.first ?? NSScreen.main
  }

  private func configureDefaultNotchInteraction() {
    defaultsToVoiceMode = hasBluetoothVoiceDevice()

    guard !defaultsToVoiceMode, let panel else { return }
    CoveStateManager.shared.transition(to: .textMode)
    overlayState = .expanded
    capsuleView?.setState(.expanded, animated: false)

    guard let screen = primaryScreen() else { return }
    let frame = panelFrame(for: .expanded, metrics: notchMetrics(for: screen))
    panel.setFrame(frame, display: true, animate: false)
    springFrame = SpringFrame(frame)
    panel.makeKeyAndOrderFront(nil)
  }

  private func hasBluetoothVoiceDevice() -> Bool {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDevices,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    var dataSize: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(
      AudioObjectID(kAudioObjectSystemObject),
      &address,
      0,
      nil,
      &dataSize
    ) == noErr else {
      return false
    }

    let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
    var devices = [AudioDeviceID](repeating: 0, count: count)
    guard AudioObjectGetPropertyData(
      AudioObjectID(kAudioObjectSystemObject),
      &address,
      0,
      nil,
      &dataSize,
      &devices
    ) == noErr else {
      return false
    }

    return devices.contains(where: isBluetoothVoiceDevice)
  }

  private func isBluetoothVoiceDevice(_ device: AudioDeviceID) -> Bool {
    var transportAddress = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyTransportType,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    var transportType: UInt32 = 0
    var transportSize = UInt32(MemoryLayout<UInt32>.size)
    guard AudioObjectGetPropertyData(
      device,
      &transportAddress,
      0,
      nil,
      &transportSize,
      &transportType
    ) == noErr,
      transportType == kAudioDeviceTransportTypeBluetooth ||
      transportType == kAudioDeviceTransportTypeBluetoothLE
    else {
      return false
    }

    var inputAddress = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyStreamConfiguration,
      mScope: kAudioDevicePropertyScopeInput,
      mElement: kAudioObjectPropertyElementMain
    )
    var inputSize: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(device, &inputAddress, 0, nil, &inputSize) == noErr,
      inputSize >= UInt32(MemoryLayout<AudioBufferList>.size)
    else {
      return false
    }

    let bufferList = UnsafeMutableRawPointer.allocate(
      byteCount: Int(inputSize),
      alignment: MemoryLayout<AudioBufferList>.alignment
    )
    defer { bufferList.deallocate() }
    guard AudioObjectGetPropertyData(
      device,
      &inputAddress,
      0,
      nil,
      &inputSize,
      bufferList
    ) == noErr else {
      return false
    }
    return bufferList.assumingMemoryBound(to: AudioBufferList.self).pointee.mNumberBuffers > 0
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
      return NSSize(width: expandedPanelWidth, height: compactPanelHeight)
    case .response:
      return NSSize(width: expandedPanelWidth, height: responsePanelHeight)
    }
  }

  private func panelFrame(for state: OverlayState, metrics: NotchMetrics) -> NSRect {
    let size = panelSize(for: state, metrics: metrics)
    let topEdge = metrics.topSafeBottomY + notchAttachOverlap

    return NSRect(
      x: metrics.centerX - size.width / 2,
      y: topEdge - size.height,
      width: size.width,
      height: size.height
    )
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
      if CoveStateManager.shared.state == .idle {
        let hoverFrame = panel.frame.insetBy(dx: -hoverSlop, dy: -hoverSlop)
        let shouldPreserveCompactSettingsClick = overlayState == .compact && isOverSettings
        let nextHoverState = hoverFrame.contains(mouseLocation) &&
          !shouldPreserveCompactSettingsClick

        if isHovering != nextHoverState {
          isHovering = nextHoverState
          print("Cove hover state:", nextHoverState ? "hovering" : "not hovering")
          setOverlayState(nextHoverState ? .expanded : .compact)
        }
      }

      let isOverPanel = panel.frame.contains(mouseLocation)
      let shouldAcceptMouseEvents = isOverSettings || isOverPanel
      if panel.ignoresMouseEvents == shouldAcceptMouseEvents {
        panel.ignoresMouseEvents = !shouldAcceptMouseEvents
        print("Cove mouse passthrough:", panel.ignoresMouseEvents ? "enabled" : "notch interaction active")
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

  private func installOutsideClickMonitoring() {
    localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
      self?.collapseNotchInteractionIfNeeded(at: NSEvent.mouseLocation)
      return event
    }
    globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
      DispatchQueue.main.async {
        self?.collapseNotchInteractionIfNeeded(at: NSEvent.mouseLocation)
      }
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

    panel.setFrame(frame, display: true, animate: false)
    springFrame = SpringFrame(frame)
    logPanelFrame(frame, reason: "screen changed")
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
      Self.spring(&frame.y, velocity: &self.springVelocity.y, target: target.y, step: step)
      Self.spring(&frame.width, velocity: &self.springVelocity.width, target: target.width, step: step)
      Self.spring(&frame.height, velocity: &self.springVelocity.height, target: target.height, step: step)

      self.springFrame = frame
      panel.setFrame(frame.rect, display: true, animate: false)

      let remainingDistance =
        abs(frame.x - target.x) +
        abs(frame.y - target.y) +
        abs(frame.width - target.width) +
        abs(frame.height - target.height)
      let remainingVelocity =
        abs(self.springVelocity.x) +
        abs(self.springVelocity.y) +
        abs(self.springVelocity.width) +
        abs(self.springVelocity.height)

      if remainingDistance < 0.7 && remainingVelocity < 0.7 {
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
    let displacement = target - value
    let force = displacement * springStiffness
    let dampingForce = velocity * springDamping
    let acceleration = force - dampingForce

    velocity += acceleration * step
    value += velocity * step
  }

  private func showSettingsWindow() {
    print("[Settings] showSettingsWindow() entered:", [
      "hasExistingController": settingsWindowController != nil,
      "appIsActive": NSApp.isActive,
      "appIsHidden": NSApp.isHidden
    ])
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

  private func sendNotchPrompt(_ prompt: String) {
    CoveStateManager.shared.transition(to: .thinking)
    let service = AIServiceFactory.makeService()

    Task { @MainActor [weak self] in
      let response: String
      do {
        response = try await service.request(input: prompt)
      } catch {
        response = error.localizedDescription
      }
      CoveStateManager.shared.transition(to: .responding)
      self?.capsuleView?.showResponse(response)
      self?.setOverlayState(.response)
    }
  }

  private func collapseNotchInteractionIfNeeded(at location: NSPoint) {
    guard let panel, !panel.frame.contains(location), CoveStateManager.shared.state != .idle else {
      return
    }
    collapseNotchInteraction()
  }

  private func collapseNotchInteraction() {
    capsuleView?.resetInteraction()
    if defaultsToVoiceMode {
      CoveStateManager.shared.transition(to: .idle)
      setOverlayState(.compact)
    } else {
      CoveStateManager.shared.transition(to: .textMode)
      setOverlayState(.expanded)
      panel?.makeKeyAndOrderFront(nil)
    }
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

import AppKit
import QuartzCore

/// Custom split layout for Cove Settings. It deliberately avoids a system
/// source-list/table layout while retaining native AppKit window behavior.
final class SettingsContainerViewController: NSViewController, SettingsSidebarViewDelegate {
  private let sidebar: SettingsSidebarView
  private let contentHost: NSView
  private var cachedViewControllers: [SettingsSection: NSViewController] = [:]
  private var currentViewController: NSViewController?

  init() {
    print("[Settings][Container Init 01] SettingsContainerViewController.init() started")
    print("[Settings][Container Init 02] Creating SettingsSidebarView")
    sidebar = SettingsSidebarView(selected: .account)
    print("[Settings][Container Init 03] SettingsSidebarView created")
    contentHost = NSView()
    print("[Settings][Container Init 04] Content host created")
    super.init(nibName: nil, bundle: nil)
    print("[Settings][Container Init 05] NSViewController.init returned")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    print("[Settings][Container Load 01] loadView() started")
    let rootView = NSVisualEffectView()
    print("[Settings][Container Load 02] Root NSVisualEffectView created")
    rootView.material = .underWindowBackground
    rootView.blendingMode = .behindWindow
    rootView.state = .followsWindowActiveState
    rootView.autoresizingMask = [.width, .height]
    print("[Settings][Container Load 03] Root visual effect configured")

    sidebar.delegate = self
    print("[Settings][Container Load 04] Sidebar delegate assigned")

    contentHost.translatesAutoresizingMaskIntoConstraints = false
    contentHost.wantsLayer = true
    contentHost.layer?.masksToBounds = true
    print("[Settings][Container Load 05] Content host configured")

    let divider = NSBox()
    print("[Settings][Container Load 06] Divider created")
    divider.boxType = .separator
    divider.translatesAutoresizingMaskIntoConstraints = false
    print("[Settings][Container Load 07] Divider configured")

    rootView.addSubview(sidebar)
    rootView.addSubview(divider)
    rootView.addSubview(contentHost)
    print("[Settings][Container Load 08] Root subviews added")

    print("[Settings][Container Load 09] Activating root constraints")
    NSLayoutConstraint.activate([
      sidebar.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
      sidebar.topAnchor.constraint(equalTo: rootView.topAnchor),
      sidebar.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
      sidebar.widthAnchor.constraint(equalToConstant: SettingsTheme.sidebarWidth),

      divider.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor),
      divider.topAnchor.constraint(equalTo: rootView.topAnchor),
      divider.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
      divider.widthAnchor.constraint(equalToConstant: 1),

      contentHost.leadingAnchor.constraint(equalTo: divider.trailingAnchor),
      contentHost.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
      contentHost.topAnchor.constraint(equalTo: rootView.topAnchor),
      contentHost.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
    ])
    print("[Settings][Container Load 10] Root constraints activated")

    view = rootView
    print("[Settings][Container Load 11] Root view assigned")
    print("[Settings][Container Load 12] Showing initial Account section")
    show(section: .account, animated: false)
    print("[Settings][Container Load 13] Initial Account section shown")
  }

  func settingsSidebar(_ sidebar: SettingsSidebarView, didSelect section: SettingsSection) {
    show(section: section, animated: true)
  }

  private func show(section: SettingsSection, animated: Bool) {
    print("[Settings][Container Show 01] show(section:) started:", section.title)
    let nextViewController: NSViewController
    if let cached = cachedViewControllers[section] {
      nextViewController = cached
    } else {
      print("[Settings][Container Show 02] Creating section view controller:", section.title)
      nextViewController = section.makeViewController()
      print("[Settings][Container Show 03] Section view controller created:", section.title)
      cachedViewControllers[section] = nextViewController
    }

    guard nextViewController !== currentViewController else { return }
    let previousViewController = currentViewController

    addChild(nextViewController)
    print("[Settings][Container Show 04] Section child added:", section.title)
    print("[Settings][Container Show 05] Accessing section view:", section.title)
    let nextView = nextViewController.view
    print("[Settings][Container Show 06] Section view loaded:", section.title)
    nextView.translatesAutoresizingMaskIntoConstraints = false
    nextView.wantsLayer = true
    contentHost.addSubview(nextView)
    print("[Settings][Container Show 07] Section view added to content host:", section.title)
    print("[Settings][Container Show 08] Activating section constraints:", section.title)
    NSLayoutConstraint.activate([
      nextView.leadingAnchor.constraint(equalTo: contentHost.leadingAnchor),
      nextView.trailingAnchor.constraint(equalTo: contentHost.trailingAnchor),
      nextView.topAnchor.constraint(equalTo: contentHost.topAnchor),
      nextView.bottomAnchor.constraint(equalTo: contentHost.bottomAnchor)
    ])
    print("[Settings][Container Show 09] Section constraints activated:", section.title)
    contentHost.layoutSubtreeIfNeeded()
    print("[Settings][Container Show 10] Section layout completed:", section.title)
    currentViewController = nextViewController

    guard animated, let previousViewController else {
      previousViewController?.view.removeFromSuperview()
      previousViewController?.removeFromParent()
      nextView.alphaValue = 1
      return
    }

    nextView.alphaValue = 0
    nextView.layer?.transform = CATransform3DMakeTranslation(10, 0, 0)

    NSAnimationContext.runAnimationGroup(
      { context in
        context.duration = SettingsTheme.sectionTransitionDuration
        context.timingFunction = CAMediaTimingFunction(name: .easeOut)
        nextView.animator().alphaValue = 1
        previousViewController.view.animator().alphaValue = 0

        CATransaction.begin()
        CATransaction.setAnimationDuration(SettingsTheme.sectionTransitionDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        nextView.layer?.transform = CATransform3DIdentity
        CATransaction.commit()
      },
      completionHandler: {
        previousViewController.view.removeFromSuperview()
        previousViewController.removeFromParent()
        previousViewController.view.alphaValue = 1
      }
    )
  }
}

import AppKit
import QuartzCore

/// Custom split layout for Cove Settings. It deliberately avoids a system
/// source-list/table layout while retaining native AppKit window behavior.
final class SettingsContainerViewController: NSViewController, SettingsSidebarViewDelegate {
  private let sidebar = SettingsSidebarView(selected: .account)
  private let contentHost = NSView()
  private var cachedViewControllers: [SettingsSection: NSViewController] = [:]
  private var currentViewController: NSViewController?

  override func loadView() {
    let rootView = NSVisualEffectView()
    rootView.material = .underWindowBackground
    rootView.blendingMode = .behindWindow
    rootView.state = .followsWindowActiveState
    rootView.translatesAutoresizingMaskIntoConstraints = false

    sidebar.delegate = self

    contentHost.translatesAutoresizingMaskIntoConstraints = false
    contentHost.wantsLayer = true
    contentHost.layer?.masksToBounds = true

    let divider = NSBox()
    divider.boxType = .separator
    divider.translatesAutoresizingMaskIntoConstraints = false

    rootView.addSubview(sidebar)
    rootView.addSubview(divider)
    rootView.addSubview(contentHost)

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

    view = rootView
    show(section: .account, animated: false)
  }

  func settingsSidebar(_ sidebar: SettingsSidebarView, didSelect section: SettingsSection) {
    show(section: section, animated: true)
  }

  private func show(section: SettingsSection, animated: Bool) {
    let nextViewController: NSViewController
    if let cached = cachedViewControllers[section] {
      nextViewController = cached
    } else {
      nextViewController = section.makeViewController()
      cachedViewControllers[section] = nextViewController
    }

    guard nextViewController !== currentViewController else { return }
    let previousViewController = currentViewController

    addChild(nextViewController)
    let nextView = nextViewController.view
    nextView.translatesAutoresizingMaskIntoConstraints = false
    nextView.wantsLayer = true
    contentHost.addSubview(nextView)
    NSLayoutConstraint.activate([
      nextView.leadingAnchor.constraint(equalTo: contentHost.leadingAnchor),
      nextView.trailingAnchor.constraint(equalTo: contentHost.trailingAnchor),
      nextView.topAnchor.constraint(equalTo: contentHost.topAnchor),
      nextView.bottomAnchor.constraint(equalTo: contentHost.bottomAnchor)
    ])
    contentHost.layoutSubtreeIfNeeded()
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

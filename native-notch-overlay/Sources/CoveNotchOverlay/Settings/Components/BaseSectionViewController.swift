import AppKit

/// Shared scaffold for every Settings section: a scroll view containing a
/// header (title + subtitle) and a vertical stack of cards. Concrete
/// sections only need to set `sectionTitle`/`sectionSubtitle` and append
/// their cards in `buildContent()`.
class BaseSectionViewController: NSViewController {
  var sectionTitle: String { "" }
  var sectionSubtitle: String? { nil }

  let contentStack = NSStackView()

  override func loadView() {
    print("[Settings][Section Load 01] BaseSectionViewController.loadView() started:", sectionTitle)
    let scrollView = NSScrollView()
    print("[Settings][Section Load 02] Scroll view created:", sectionTitle)
    scrollView.drawsBackground = false
    scrollView.hasVerticalScroller = true
    scrollView.autohidesScrollers = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    print("[Settings][Section Load 03] Scroll view configured:", sectionTitle)

    contentStack.orientation = .vertical
    contentStack.alignment = .leading
    contentStack.spacing = SettingsTheme.cardSpacing
    contentStack.detachesHiddenViews = true
    contentStack.edgeInsets = NSEdgeInsets(
      top: SettingsTheme.contentInset,
      left: SettingsTheme.contentInset,
      bottom: SettingsTheme.contentInset,
      right: SettingsTheme.contentInset
    )
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    print("[Settings][Section Load 04] Content stack configured:", sectionTitle)

    let documentView = FlippedView()
    print("[Settings][Section Load 05] Document view created:", sectionTitle)
    documentView.translatesAutoresizingMaskIntoConstraints = false
    documentView.addSubview(contentStack)
    print("[Settings][Section Load 06] Content stack added to document view:", sectionTitle)

    print("[Settings][Section Load 07] Activating content stack constraints:", sectionTitle)
    NSLayoutConstraint.activate([
      contentStack.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
      contentStack.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
      contentStack.topAnchor.constraint(equalTo: documentView.topAnchor),
      contentStack.bottomAnchor.constraint(equalTo: documentView.bottomAnchor)
    ])
    print("[Settings][Section Load 08] Content stack constraints activated:", sectionTitle)

    scrollView.documentView = documentView
    print("[Settings][Section Load 09] Scroll document view assigned:", sectionTitle)
    print("[Settings][Section Load 10] Activating document width constraint:", sectionTitle)
    NSLayoutConstraint.activate([
      documentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
    ])
    print("[Settings][Section Load 11] Document width constraint activated:", sectionTitle)

    view = scrollView
    print("[Settings][Section Load 12] Section root view assigned:", sectionTitle)

    print("[Settings][Section Load 13] Adding section header:", sectionTitle)
    addHeader()
    print("[Settings][Section Load 14] Section header added:", sectionTitle)
    print("[Settings][Section Load 15] Building section content:", sectionTitle)
    buildContent()
    print("[Settings][Section Load 16] Section content built:", sectionTitle)
  }

  /// Override to append cards via `contentStack.addArrangedSubview(_:)`.
  func buildContent() {}

  private func addHeader() {
    print("[Settings][Section Header 01] Creating title label:", sectionTitle)
    let title = NSTextField(labelWithString: sectionTitle)
    title.font = SettingsTheme.titleFont
    title.textColor = .labelColor
    print("[Settings][Section Header 02] Title label configured:", sectionTitle)

    let headerStack = NSStackView(views: [title])
    print("[Settings][Section Header 03] Header stack created:", sectionTitle)
    headerStack.orientation = .vertical
    headerStack.alignment = .leading
    headerStack.spacing = 4
    headerStack.setHuggingPriority(.required, for: .vertical)
    print("[Settings][Section Header 04] Header stack configured:", sectionTitle)

    if let sectionSubtitle {
      print("[Settings][Section Header 05] Creating subtitle label:", sectionTitle)
      let subtitle = NSTextField(wrappingLabelWithString: sectionSubtitle)
      subtitle.font = SettingsTheme.subtitleFont
      subtitle.textColor = .secondaryLabelColor
      headerStack.addArrangedSubview(subtitle)
      print("[Settings][Section Header 06] Subtitle added; activating width constraint:", sectionTitle)
      subtitle.widthAnchor.constraint(
        equalTo: contentStack.widthAnchor, constant: -(SettingsTheme.contentInset * 2)
      ).isActive = true
      print("[Settings][Section Header 07] Subtitle width constraint activated:", sectionTitle)
    }

    contentStack.addArrangedSubview(headerStack)
    print("[Settings][Section Header 08] Header added to content stack:", sectionTitle)
    headerStack.widthAnchor.constraint(
      equalTo: contentStack.widthAnchor, constant: -(SettingsTheme.contentInset * 2)
    ).isActive = true
    print("[Settings][Section Header 09] Header width constraint activated:", sectionTitle)
  }

  func addCard(_ card: NSView) {
    contentStack.addArrangedSubview(card)
    card.widthAnchor.constraint(
      equalTo: contentStack.widthAnchor, constant: -(SettingsTheme.contentInset * 2)
    ).isActive = true
  }
}

/// A document view whose coordinate system starts at the top, so stacked
/// content lays out top-down inside the scroll view like a normal page.
final class FlippedView: NSView {
  override var isFlipped: Bool { true }
}

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
    let scrollView = NSScrollView()
    scrollView.drawsBackground = false
    scrollView.hasVerticalScroller = true
    scrollView.autohidesScrollers = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false

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

    let documentView = FlippedView()
    documentView.translatesAutoresizingMaskIntoConstraints = false
    documentView.addSubview(contentStack)

    NSLayoutConstraint.activate([
      contentStack.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
      contentStack.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
      contentStack.topAnchor.constraint(equalTo: documentView.topAnchor),
      contentStack.bottomAnchor.constraint(equalTo: documentView.bottomAnchor)
    ])

    scrollView.documentView = documentView
    NSLayoutConstraint.activate([
      documentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
    ])

    view = scrollView

    addHeader()
    buildContent()
  }

  /// Override to append cards via `contentStack.addArrangedSubview(_:)`.
  func buildContent() {}

  private func addHeader() {
    let title = NSTextField(labelWithString: sectionTitle)
    title.font = SettingsTheme.titleFont
    title.textColor = .labelColor

    let headerStack = NSStackView(views: [title])
    headerStack.orientation = .vertical
    headerStack.alignment = .leading
    headerStack.spacing = 4
    headerStack.setHuggingPriority(.required, for: .vertical)

    if let sectionSubtitle {
      let subtitle = NSTextField(wrappingLabelWithString: sectionSubtitle)
      subtitle.font = SettingsTheme.subtitleFont
      subtitle.textColor = .secondaryLabelColor
      headerStack.addArrangedSubview(subtitle)
      subtitle.widthAnchor.constraint(
        equalTo: contentStack.widthAnchor, constant: -(SettingsTheme.contentInset * 2)
      ).isActive = true
    }

    contentStack.addArrangedSubview(headerStack)
    headerStack.widthAnchor.constraint(
      equalTo: contentStack.widthAnchor, constant: -(SettingsTheme.contentInset * 2)
    ).isActive = true
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

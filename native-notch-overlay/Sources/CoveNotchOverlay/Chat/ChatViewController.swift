import AppKit

final class ChatViewController: NSViewController {
  private let conversationStack = NSStackView()
  private let conversationScrollView = NSScrollView()
  private let inputTextView = NSTextView()
  private let inputScrollView = NSScrollView()
  private let sendButton = PillButton(title: "Send", style: .filled)

  override func loadView() {
    let rootView = NSView()
    rootView.translatesAutoresizingMaskIntoConstraints = false

    conversationStack.orientation = .vertical
    conversationStack.alignment = .leading
    conversationStack.spacing = 12
    conversationStack.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    conversationStack.translatesAutoresizingMaskIntoConstraints = false

    let documentView = FlippedView()
    documentView.translatesAutoresizingMaskIntoConstraints = false
    documentView.addSubview(conversationStack)
    NSLayoutConstraint.activate([
      conversationStack.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
      conversationStack.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
      conversationStack.topAnchor.constraint(equalTo: documentView.topAnchor),
      conversationStack.bottomAnchor.constraint(equalTo: documentView.bottomAnchor)
    ])

    conversationScrollView.drawsBackground = false
    conversationScrollView.hasVerticalScroller = true
    conversationScrollView.autohidesScrollers = true
    conversationScrollView.documentView = documentView
    conversationScrollView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      documentView.widthAnchor.constraint(equalTo: conversationScrollView.contentView.widthAnchor),
      documentView.heightAnchor.constraint(greaterThanOrEqualTo: conversationScrollView.contentView.heightAnchor)
    ])

    inputTextView.font = .systemFont(ofSize: 13)
    inputTextView.isRichText = false
    inputTextView.allowsUndo = true
    inputTextView.drawsBackground = false
    inputTextView.textContainerInset = NSSize(width: 8, height: 8)
    inputTextView.isHorizontallyResizable = false
    inputTextView.textContainer?.widthTracksTextView = true

    inputScrollView.borderType = .bezelBorder
    inputScrollView.hasVerticalScroller = true
    inputScrollView.autohidesScrollers = true
    inputScrollView.documentView = inputTextView
    inputScrollView.translatesAutoresizingMaskIntoConstraints = false

    sendButton.target = self
    sendButton.action = #selector(sendMessage)
    sendButton.widthAnchor.constraint(equalToConstant: 72).isActive = true

    let inputRow = NSStackView(views: [inputScrollView, sendButton])
    inputRow.orientation = .horizontal
    inputRow.alignment = .bottom
    inputRow.spacing = 12
    inputRow.translatesAutoresizingMaskIntoConstraints = false

    rootView.addSubview(conversationScrollView)
    rootView.addSubview(inputRow)
    NSLayoutConstraint.activate([
      conversationScrollView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20),
      conversationScrollView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20),
      conversationScrollView.topAnchor.constraint(equalTo: rootView.topAnchor, constant: 20),
      conversationScrollView.bottomAnchor.constraint(equalTo: inputRow.topAnchor, constant: -16),

      inputRow.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20),
      inputRow.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20),
      inputRow.bottomAnchor.constraint(equalTo: rootView.bottomAnchor, constant: -20),
      inputScrollView.heightAnchor.constraint(equalToConstant: 88)
    ])

    view = rootView
  }

  @objc private func sendMessage() {
    let message = inputTextView.string.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !message.isEmpty else { return }

    sendButton.isEnabled = false
    inputTextView.string = ""
    appendMessage(message, sender: "You")
    CoveStateManager.shared.transition(to: .thinking)

    let service = AIServiceFactory.makeService()
    Task { [weak self] in
      do {
        let response = try await service.request(input: message)
        CoveStateManager.shared.transition(to: .responding)
        self?.appendMessage(response, sender: "Cove")
      } catch {
        self?.appendMessage(error.localizedDescription, sender: "Cove")
      }
      CoveStateManager.shared.transition(to: .idle)
      self?.sendButton.isEnabled = true
    }
  }

  private func appendMessage(_ text: String, sender: String) {
    let senderLabel = NSTextField(labelWithString: sender)
    senderLabel.font = .systemFont(ofSize: 12, weight: .semibold)
    senderLabel.textColor = .secondaryLabelColor

    let messageLabel = NSTextField(wrappingLabelWithString: text)
    messageLabel.font = .systemFont(ofSize: 13)
    messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    let messageStack = NSStackView(views: [senderLabel, messageLabel])
    messageStack.orientation = .vertical
    messageStack.alignment = .leading
    messageStack.spacing = 4
    messageStack.translatesAutoresizingMaskIntoConstraints = false
    conversationStack.addArrangedSubview(messageStack)
    messageStack.widthAnchor.constraint(equalTo: conversationStack.widthAnchor).isActive = true

    view.layoutSubtreeIfNeeded()
    conversationScrollView.documentView?.scrollToEndOfDocument(nil)
  }
}

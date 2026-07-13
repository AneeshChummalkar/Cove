import AppKit

final class PermissionsViewController: BaseSectionViewController {
  override var sectionTitle: String { "Permissions" }
  override var sectionSubtitle: String? {
    "Cove will request access only when a feature needs it. Status detection is not connected yet."
  }

  override func buildContent() {
    let permissions: [(String, String, String)] = [
      (
        "accessibility",
        "Accessibility",
        "Allow Cove to understand and assist with controls in approved applications."
      ),
      (
        "rectangle.inset.filled.and.person.filled",
        "Screen Recording",
        "Let Cove see approved on-screen context when you explicitly request help."
      ),
      (
        "mic.fill",
        "Microphone",
        "Enable voice-first requests and natural follow-up conversation."
      ),
      (
        "bell.fill",
        "Notifications",
        "Receive task progress, approval requests, and completion updates."
      ),
      (
        "camera.fill",
        "Camera",
        "Support future opt-in visual context and identity verification."
      )
    ]

    for permission in permissions {
      addCard(PermissionCard(
        symbolName: permission.0,
        name: permission.1,
        description: permission.2,
        status: "Not Checked",
        actionTitle: "Review"
      ))
    }
  }
}

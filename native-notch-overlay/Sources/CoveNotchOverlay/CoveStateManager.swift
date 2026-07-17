import Foundation

enum CoveState: String {
  case idle
  case listening
  case thinking
  case responding
  case speaking
  case textMode
}

final class CoveStateManager {
  static let shared = CoveStateManager()

  static let didChangeNotification = Notification.Name("CoveStateManager.didChange")
  private(set) var state: CoveState = .idle

  private init() {}

  func transition(to state: CoveState) {
    guard self.state != state else { return }
    self.state = state
    NotificationCenter.default.post(
      name: Self.didChangeNotification,
      object: self,
      userInfo: ["state": state]
    )
  }
}

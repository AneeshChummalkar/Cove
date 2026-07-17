import Foundation

protocol AIService {
  func request(input: String) async throws -> String
}

enum AIServiceError: LocalizedError {
  case notImplemented(provider: AIProvider)

  var errorDescription: String? {
    switch self {
    case .notImplemented(let provider):
      return "\(provider.displayName) is not implemented."
    }
  }
}

final class OpenAIService: AIService {
  private let client: OpenAIClient

  init(client: OpenAIClient = OpenAIClient()) {
    self.client = client
  }

  func request(input: String) async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
      client.send(input: input) { result in
        continuation.resume(with: result.map(\.outputText))
      }
    }
  }
}

final class ClaudeService: AIService {
  func request(input: String) async throws -> String {
    throw AIServiceError.notImplemented(provider: .claude)
  }
}

final class GeminiService: AIService {
  func request(input: String) async throws -> String {
    throw AIServiceError.notImplemented(provider: .gemini)
  }
}

final class OllamaService: AIService {
  func request(input: String) async throws -> String {
    throw AIServiceError.notImplemented(provider: .local)
  }
}

enum AIServiceFactory {
  static func makeService(settingsStore: SettingsStore = .shared) -> any AIService {
    switch settingsStore.aiProvider {
    case .openAI:
      return OpenAIService()
    case .claude:
      return ClaudeService()
    case .gemini:
      return GeminiService()
    case .local:
      return OllamaService()
    }
  }
}

import Foundation

struct OpenAIResponse: Decodable {
  let id: String
  let model: String
  let output: [OutputItem]

  var outputText: String {
    output
      .flatMap(\.content)
      .filter { $0.type == "output_text" }
      .compactMap(\.text)
      .joined()
  }

  struct OutputItem: Decodable {
    let content: [Content]

    private enum CodingKeys: String, CodingKey {
      case content
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      content = try container.decodeIfPresent([Content].self, forKey: .content) ?? []
    }
  }

  struct Content: Decodable {
    let type: String
    let text: String?
  }
}

struct OpenAIAPIError: Decodable {
  let message: String
  let type: String?
  let code: String?
  let param: String?
}

enum OpenAIClientError: LocalizedError {
  case missingAPIKey
  case invalidResponse
  case requestEncoding(Error)
  case transport(Error)
  case api(statusCode: Int, error: OpenAIAPIError)
  case response(OpenAIAPIError)
  case responseDecoding(Error)

  var errorDescription: String? {
    switch self {
    case .missingAPIKey:
      return "No OpenAI API key is configured."
    case .invalidResponse:
      return "OpenAI returned an invalid HTTP response."
    case .requestEncoding(let error):
      return "The OpenAI request could not be encoded: \(error.localizedDescription)"
    case .transport(let error):
      return "The OpenAI request failed: \(error.localizedDescription)"
    case .api(let statusCode, let error):
      return "OpenAI returned HTTP \(statusCode): \(error.message)"
    case .response(let error):
      return "OpenAI could not complete the response: \(error.message)"
    case .responseDecoding(let error):
      return "The OpenAI response could not be decoded: \(error.localizedDescription)"
    }
  }
}

final class OpenAIClient {
  typealias Completion = (Result<OpenAIResponse, OpenAIClientError>) -> Void

  private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
  private let session: URLSession
  private let settingsStore: SettingsStore
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  init(
    session: URLSession = .shared,
    settingsStore: SettingsStore = .shared
  ) {
    self.session = session
    self.settingsStore = settingsStore
  }

  func send(input: String, completion: @escaping Completion) {
    guard let savedKey = settingsStore.openAIAPIKey else {
      completion(.failure(.missingAPIKey))
      return
    }

    let apiKey = savedKey.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !apiKey.isEmpty else {
      completion(.failure(.missingAPIKey))
      return
    }

    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

    do {
      request.httpBody = try encoder.encode(
        RequestBody(model: settingsStore.openAIModel.rawValue, input: input)
      )
    } catch {
      completion(.failure(.requestEncoding(error)))
      return
    }

    session.dataTask(with: request) { [decoder] data, response, error in
      if let error {
        completion(.failure(.transport(error)))
        return
      }

      guard let httpResponse = response as? HTTPURLResponse,
            let data else {
        completion(.failure(.invalidResponse))
        return
      }

      guard (200...299).contains(httpResponse.statusCode) else {
        if let envelope = try? decoder.decode(ErrorEnvelope.self, from: data) {
          completion(.failure(.api(statusCode: httpResponse.statusCode, error: envelope.error)))
        } else {
          let fallback = OpenAIAPIError(
            message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode),
            type: nil,
            code: nil,
            param: nil
          )
          completion(.failure(.api(statusCode: httpResponse.statusCode, error: fallback)))
        }
        return
      }

      do {
        let envelope = try decoder.decode(ResponseEnvelope.self, from: data)
        if let responseError = envelope.error {
          completion(.failure(.response(responseError)))
        } else {
          completion(.success(envelope.response))
        }
      } catch {
        completion(.failure(.responseDecoding(error)))
      }
    }.resume()
  }

  private struct RequestBody: Encodable {
    let model: String
    let input: String
  }

  private struct ErrorEnvelope: Decodable {
    let error: OpenAIAPIError
  }

  private struct ResponseEnvelope: Decodable {
    let response: OpenAIResponse
    let error: OpenAIAPIError?

    init(from decoder: Decoder) throws {
      response = try OpenAIResponse(from: decoder)
      let container = try decoder.container(keyedBy: CodingKeys.self)
      error = try container.decodeIfPresent(OpenAIAPIError.self, forKey: .error)
    }

    private enum CodingKeys: String, CodingKey {
      case error
    }
  }
}

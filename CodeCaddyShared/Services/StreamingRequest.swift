//
//  StreamingRequest.swift
//  CodeCaddyShared
//
//  Created by Chris Golding on 4/30/23.
//

import Foundation

public struct CompletionsParameters: Codable, Equatable, Hashable, Identifiable {
    public let id: UUID = .init()
    public let model: CompletionsModel = .gpt35Turbo
    public var prompt: String
    public let maxTokens: Int = 75
    public let temperature: Double = 1.4
    public let topP: Int? = nil
    public let n: Int = 1
    public let stream: Bool? = true
    public let logprobs: String? = nil
    public let stop: String? = nil

    public init(prompt: String) {
        self.prompt = prompt
    }

    public enum CodingKeys: String, CodingKey {
        case model, prompt
        case maxTokens = "max_tokens"
        case temperature
        case topP = "top_p"
        case n, stream, logprobs, stop
    }
}

public enum CompletionsModel: String, Codable, Equatable, Hashable {
    case gpt4 = "gpt-4"
    case gpt35Turbo = "gpt-3.5-turbo"
    case textDavinci3 = "text-davinci-003"
}

public enum ServiceError: Error {
    case invalidResponseType
    case jsonDecoding
}

public struct CompletionsResponse: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public var object: String
    public var created: Date
    public var model: String
    public var choices: [String]
    public var usage: String?
}

public class StreamingRequest: ObservableObject {
    private var apiKey = ""

    @Published var output: String = ""

    public init() {}

    public func makeCompletionsCallStream(parameters: CompletionsParameters) async throws {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("g0ld2k", forHTTPHeaderField: "OpenAI-Organization")
        request.httpMethod = "POST"

        print("After setting fields")

        let encoder = JSONEncoder()
        let json = try encoder.encode(parameters)

        request.httpBody = json

        do {
            print("before request")
            let (bytes, response) = try await URLSession.shared.bytes(for: request)

            print("After await")

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServiceError.invalidResponseType
            }
            guard (200 ... 299).contains(httpResponse.statusCode) else {
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            }
            for try await byte in bytes.lines {
                print("Received bytes")
                let line = byte.replacingOccurrences(of: "data: ", with: "").replacingOccurrences(of: "[DONE]", with: "")
                if !line.isEmpty {
                    print(line)
                    //            let obj : CompletionsResponse = try decode(data: line.data(using: .utf8))
                    guard let d = line.data(using: .utf8),
                          let obj = try? JSONDecoder().decode(CompletionsResponse.self, from: d)
                    else { throw ServiceError.jsonDecoding }

                    print(obj) // Each completion's object for streaming.
                }
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
}

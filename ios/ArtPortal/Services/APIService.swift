import Foundation

actor APIService {
    static let shared = APIService()

    /// Base URL for the ArtPortal Flask backend.
    /// Change this to your server's address when deploying.
    #if DEBUG
    private let baseURL = "http://localhost:5000"
    #else
    private let baseURL = "https://artportal.example.com"
    #endif

    func fetchObservations() async throws -> [Observation] {
        guard let url = URL(string: "\(baseURL)/api/observations") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }

        let decoded = try JSONDecoder().decode(ObservationsResponse.self, from: data)
        return decoded.observations
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ogiltig URL"
        case .serverError:
            return "Kunde inte hämta observationer från servern"
        }
    }
}

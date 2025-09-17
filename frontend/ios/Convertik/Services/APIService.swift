import Foundation

final class APIService {
    static let shared = APIService()

    private let baseURL: URL
    private let session: URLSession

    private init() {
        // Используем продакшн backend для всех режимов
        self.baseURL = URL(string: "https://api.convertik.ponravilos.ru/api/v1")!

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - Rates API

    func fetchRates() async throws -> RatesResponse {
        let url = baseURL.appendingPathComponent("rates")

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Поддерживаем формат с микросекундами: "2025-08-02T14:15:13.649148Z"
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            // Fallback к стандартному ISO8601 без микросекунд
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date string does not match expected format"
            )
        }

        return try decoder.decode(RatesResponse.self, from: data)
    }

    func fetchCurrencyNames() async throws -> CurrencyNamesResponse {
        let url = baseURL.appendingPathComponent("currency-names")

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Поддерживаем формат с микросекундами: "2025-08-02T14:15:13.649148Z"
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            // Fallback к стандартному ISO8601 без микросекунд
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date string does not match expected format"
            )
        }

        return try decoder.decode(CurrencyNamesResponse.self, from: data)
    }

    // MARK: - Stats API

    func sendStats(_ events: [StatsEvent]) async throws {
        let url = baseURL.appendingPathComponent("stats")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(events)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }
    }

    // MARK: - Push Registration

    func registerPushToken(_ token: String, deviceId: String, isPremium: Bool) async throws {
        let url = baseURL.appendingPathComponent("push/register")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = [
            "device_id": deviceId,
            "token": token,
            "platform": "ios",
            "locale": Locale.current.identifier,
            "is_premium": isPremium,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ] as [String: Any]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .invalidResponse:
            return "Неверный ответ сервера"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        }
    }
}

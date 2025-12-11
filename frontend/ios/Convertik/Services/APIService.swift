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

    // MARK: - Date Parsing Helper

    /// Парсит строку даты в различных форматах ISO8601
    /// Поддерживает форматы с "Z" (UTC), с часовым поясом (+03:00), с микросекундами
    private func parseDate(from dateString: String, container: SingleValueDecodingContainer) throws -> Date {
        // Поддерживаем различные форматы ISO8601:
        // 1. С "Z" (UTC): "2025-12-11T06:06:00Z"
        // 2. С часовым поясом: "2025-12-11T06:06:00+03:00"
        // 3. С микросекундами: "2025-12-11T06:06:00.123456Z"

        // Используем ISO8601DateFormatter, который автоматически обрабатывает часовые пояса
        let formatter = ISO8601DateFormatter()

        // Пробуем сначала с микросекундами
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date
        }

        // Fallback к стандартному ISO8601 без микросекунд
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            return date
        }

        // Если не удалось распарсить, пробуем через DateFormatter для более гибкого парсинга
        let flexibleFormatter = DateFormatter()
        flexibleFormatter.locale = Locale(identifier: "en_US_POSIX")
        flexibleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        flexibleFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = flexibleFormatter.date(from: dateString) {
            return date
        }

        flexibleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let date = flexibleFormatter.date(from: dateString) {
            return date
        }

        // Пробуем парсить с часовым поясом (например, +03:00)
        flexibleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let date = flexibleFormatter.date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Date string does not match expected format: \(dateString)"
        )
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
            return try self.parseDate(from: dateString, container: container)
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
            return try self.parseDate(from: dateString, container: container)
        }

        return try decoder.decode(CurrencyNamesResponse.self, from: data)
    }

    // MARK: - Stats API

    func sendStats(_ events: [StatsEvent]) async throws {
        let url = baseURL.appendingPathComponent("stats")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ВАЖНО: Backend ожидает объект с полем "events", а не массив напрямую
        let batch = StatsEventBatch(events: events)

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(batch)

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

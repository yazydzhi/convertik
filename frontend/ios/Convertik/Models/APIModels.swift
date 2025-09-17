import Foundation

// MARK: - API Response Models

struct RatesResponse: Codable {
    let updatedAt: Date
    let base: String
    let rates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case base
        case rates
    }
}

struct CurrencyNamesResponse: Codable {
    let updatedAt: Date
    let names: [String: String]

    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case names
    }
}

struct StatsEvent: Codable {
    let name: String
    let deviceId: String
    let timestamp: Int
    let params: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case name
        case deviceId = "device_id"
        case timestamp = "ts"
        case params
    }
}

// Helper для Any в JSON
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else {
            throw DecodingError.typeMismatch(
                AnyCodable.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type")
            )
        }
    }
}

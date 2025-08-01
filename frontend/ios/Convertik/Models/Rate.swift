import Foundation

struct Rate: Codable, Identifiable, Hashable {
    let code: String
    let name: String
    let value: Double // Сколько рублей за 1 единицу валюты
    let updatedAt: Date

    var id: String { code }

    init(code: String, name: String, value: Double, updatedAt: Date = Date()) {
        self.code = code
        self.name = name
        self.value = value
        self.updatedAt = updatedAt
    }
}

extension Rate {
    // Конвертация из CoreData
    init(from entity: RateEntity) {
        self.code = entity.code
        self.name = entity.name
        self.value = entity.value
        self.updatedAt = entity.updatedAt
    }

    var displayName: String {
        name
    }
}

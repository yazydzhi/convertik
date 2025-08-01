import Foundation

struct UserCurrency: Identifiable, Hashable {
    let code: String
    let isEnabled: Bool
    let order: Int

    var id: String { code }

    init(code: String, isEnabled: Bool = true, order: Int = 0) {
        self.code = code
        self.isEnabled = isEnabled
        self.order = order
    }
}

extension UserCurrency {
    // Конвертация из CoreData
    init(from entity: UserCurrencyEntity) {
        self.code = entity.code
        self.isEnabled = entity.isEnabled
        self.order = Int(entity.order)
    }
}

import CoreData
import Foundation

@objc(UserCurrencyEntity)
public class UserCurrencyEntity: NSManagedObject {

}

extension UserCurrencyEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCurrencyEntity> {
        return NSFetchRequest<UserCurrencyEntity>(entityName: "UserCurrencyEntity")
    }

    @NSManaged public var code: String
    @NSManaged public var isEnabled: Bool
    @NSManaged public var order: Int16
}

extension UserCurrencyEntity: Identifiable {
    public var id: String { code }
}

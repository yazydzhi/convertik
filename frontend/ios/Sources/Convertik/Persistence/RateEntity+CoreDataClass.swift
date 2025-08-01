import CoreData
import Foundation

@objc(RateEntity)
public class RateEntity: NSManagedObject {
    
}

extension RateEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RateEntity> {
        return NSFetchRequest<RateEntity>(entityName: "RateEntity")
    }
    
    @NSManaged public var code: String
    @NSManaged public var name: String
    @NSManaged public var value: Double
    @NSManaged public var updatedAt: Date
}

extension RateEntity: Identifiable {
    public var id: String { code }
}
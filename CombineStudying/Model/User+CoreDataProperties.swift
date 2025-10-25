//
//  User+CoreDataProperties.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//
//

public import Foundation
public import CoreData


public typealias UserCoreDataPropertiesSet = NSSet

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var password: String?

}

extension User : Identifiable {

}

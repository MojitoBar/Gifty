//
//  Contact+CoreDataProperties.swift
//  QRCode-Example
//
//  Created by judongseok on 2022/04/20.
//  Copyright © 2022 Hans Knoechel. All rights reserved.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var image: Data?

}

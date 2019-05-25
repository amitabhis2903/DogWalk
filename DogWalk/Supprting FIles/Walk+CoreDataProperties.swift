//
//  Walk+CoreDataProperties.swift
//  DogWalk
//
//  Created by A on 25/05/19.
//  Copyright © 2019 A. All rights reserved.
//
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var dog: Dog?

}

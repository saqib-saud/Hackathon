//
//  Weather+CoreDataProperties.swift
//  WeatherMan
//
//  Created by Saqib Saud on 4/15/16.
//  Copyright © 2016 Saqib Saud. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Weather {

    @NSManaged var date: NSDate?
    @NSManaged var minTemp: NSNumber?
    @NSManaged var maxTemp: NSNumber?
    @NSManaged var weatherDescription: String?
    @NSManaged var weatherIcon: String?

}

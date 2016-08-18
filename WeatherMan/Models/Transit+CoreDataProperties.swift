//
//  Transit+CoreDataProperties.swift
//  WeatherMan
//
//  Created by Saqib Saud on 18/08/2016.
//  Copyright © 2016 Saqib Saud. All rights reserved.
//

import Foundation
import CoreData

extension Transit {
    
    @NSManaged var arrivalTime: String?
    @NSManaged var departureTime: String?
    @NSManaged var numberOfStops: NSNumber?
    @NSManaged var priceInEuros: String?
    @NSManaged var providerLogo: String?
    @NSManaged var transitId: NSNumber?
    @NSManaged var transitType: String?

}

//
//  Weather.swift
//  WeatherMan
//
//  Created by Saqib Saud on 4/15/16.
//  Copyright © 2016 Saqib Saud. All rights reserved.
//

import Foundation
import CoreData


class Weather: NSManagedObject {
    static let entityName = "Weather"

    static let timestampFormatter: NSDateFormatter = {
        let timestampFormatter = NSDateFormatter()
        timestampFormatter.dateFormat = "EEEE"
        return timestampFormatter
    }()
}

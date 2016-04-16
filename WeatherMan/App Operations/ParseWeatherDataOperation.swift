//
//  ParseWeatherDataOperation.swift
//  WeatherMan
//
//  Created by Saqib Saud on 4/15/16.
//  Copyright © 2016 Saqib Saud. All rights reserved.
//

import Foundation
import CoreData


private struct ParsedWeather {
    // MARK: Properties.
    
    let date: NSDate
    
    let minTemperature, maxTemperature: NSNumber
    let weatherIcon, weatherDescription: String
    
    
    // MARK: Initialization
    
    init?(weather: [String: AnyObject]) {
        let temperature = weather["temp"] as? [String: AnyObject] ?? [:]
        let climate = weather["weather"] as! [AnyObject] ?? []
        let weathDetails = climate.first as? [String: AnyObject] ?? [:]

        minTemperature = temperature["min"] as? NSNumber ?? NSNumber(double: 0)
        maxTemperature = temperature["max"] as? NSNumber ?? NSNumber(double: 0)
        weatherIcon = weathDetails["icon"] as? String ?? ""
        weatherDescription = weathDetails["description"] as? String ?? ""

        if let offset = weather["dt"] as? Double {
            date = NSDate(timeIntervalSince1970: offset)
        }
        else {
            date = NSDate.distantFuture()
        }
    }
}


class ParseWeatherDataOperation: Operation {
    let cacheFile: NSURL
    let context: NSManagedObjectContext
    
    /**
     - parameter cacheFile: The file `NSURL` from which to load earthquake data.
     - parameter context: The `NSManagedObjectContext` that will be used as the
     basis for importing data. The operation will internally
     construct a new `NSManagedObjectContext` that points
     to the same `NSPersistentStoreCoordinator` as the
     passed-in context.
     */
    init(cacheFile: NSURL, context: NSManagedObjectContext) {
        let importContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        
        /*
         Use the overwrite merge policy, because we want any updated objects
         to replace the ones in the store.
         */
        importContext.mergePolicy = NSOverwriteMergePolicy
        
        self.cacheFile = cacheFile
        self.context = importContext
        
        super.init()
        
        name = "Parse Weather data"
    }
    
    override func execute() {
        guard let stream = NSInputStream(URL: cacheFile) else {
            finish()
            return
        }
        
        stream.open()
        
        defer {
            stream.close()
        }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithStream(stream, options: []) as? [String: AnyObject]
            
            if let features = json?["list"] as? [[String: AnyObject]] {
                parse(features)
            }
            else {
                finish()
            }
        }
        catch let jsonError as NSError {
            finishWithError(jsonError)
        }
    }
    
    private func parse(features: [[String: AnyObject]]) {
        let parsedEarthquakes = features.flatMap { ParsedWeather(weather: $0) }
        
        context.performBlock {
            for newEarthquake in parsedEarthquakes {
                self.insert(newEarthquake)
            }
            
            let error = self.saveContext()
            self.finishWithError(error)
        }
    }
    
    private func insert(parsed: ParsedWeather) {
        let weather = NSEntityDescription.insertNewObjectForEntityForName(Weather.entityName, inManagedObjectContext: context) as! Weather
        
        weather.date = parsed.date
        weather.minTemp = parsed.minTemperature
        weather.maxTemp = parsed.maxTemperature
        weather.weatherIcon = parsed.weatherIcon
        weather.weatherDescription = parsed.weatherDescription
    }
    
    /**
     Save the context, if there are any changes.
     
     - returns: An `NSError` if there was an problem saving the `NSManagedObjectContext`,
     otherwise `nil`.
     
     - note: This method returns an `NSError?` because it will be immediately
     passed to the `finishWithError()` method, which accepts an `NSError?`.
     */
    private func saveContext() -> NSError? {
        var error: NSError?
        
        if context.hasChanges {
            do {
                try context.save()
            }
            catch let saveError as NSError {
                error = saveError
            }
        }
        
        return error
    }
}

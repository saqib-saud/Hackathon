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
    
    let numberOfStops, transitId: NSNumber
    let departureTime, arrivalTime, providerLogo, priceInEuros: String
    let webservice:WebServiceConstants
    
    // MARK: Initialization
    
    init?(weather: [String: AnyObject], webservice:WebServiceConstants) {
        transitId = weather["id"] as? NSNumber ?? NSNumber(double: 0)
        providerLogo = weather["provider_logo"] as? String ?? ""
        priceInEuros = weather["price_in_euros"] as? String ?? String(weather["price_in_euros"] as! NSNumber)
        departureTime = weather["departure_time"] as? String ?? ""
        arrivalTime = weather["arrival_time"] as? String ?? ""
        numberOfStops = weather["number_of_stops"] as? NSNumber ?? NSNumber(double: 0)
        self.webservice = webservice
    }
}


class ParseWeatherDataOperation: Operation {
    let cacheFile: NSURL
    let context: NSManagedObjectContext
    let webservice:WebServiceConstants
    /**
     - parameter cacheFile: The file `NSURL` from which to load earthquake data.
     - parameter context: The `NSManagedObjectContext` that will be used as the
     basis for importing data. The operation will internally
     construct a new `NSManagedObjectContext` that points
     to the same `NSPersistentStoreCoordinator` as the
     passed-in context.
     */
    init(cacheFile: NSURL, context: NSManagedObjectContext, webservice:WebServiceConstants) {
        let importContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        self.webservice = webservice
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
            let json = try NSJSONSerialization.JSONObjectWithStream(stream, options: []) as? [[String: AnyObject]]
            
            if let _ = json {
                parse(json!)
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
        let parsedEarthquakes = features.flatMap { ParsedWeather(weather: $0, webservice: self.webservice)}
        
        context.performBlock {
            for newEarthquake in parsedEarthquakes {
                self.insert(newEarthquake)
            }
            
            let error = self.saveContext()
            self.finishWithError(error)
        }
    }
    
    private func insert(parsed: ParsedWeather) {
        let transit = NSEntityDescription.insertNewObjectForEntityForName(Transit.entityName, inManagedObjectContext: context) as! Transit
        
        transit.transitId = parsed.transitId
        transit.providerLogo = parsed.providerLogo
        transit.priceInEuros = parsed.priceInEuros
        transit.arrivalTime = parsed.arrivalTime
        transit.departureTime = parsed.departureTime
        transit.priceInEuros = parsed.priceInEuros
        transit.transitType = webservice.rawValue
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

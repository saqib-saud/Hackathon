//
//  DownloadWeatherOperation.swift
//  WeatherMan
//
//  Created by Saqib Saud on 4/15/16.
//  Copyright © 2016 Saqib Saud. All rights reserved.
//

import Foundation
import MapKit

class DownloadWeatherOperation: GroupOperation {
    // MARK: Properties
    
    let cacheFile: NSURL
    
    // MARK: Initialization
    
    /// - parameter cacheFile: The file `NSURL` to which the earthquake feed will be downloaded.
    init(location:CLLocation, cacheFile: NSURL) {
        self.cacheFile = cacheFile
        super.init(operations: [])
        name = "Download Weather Forecast"
        
        /*
         Since this server is out of our control and does not offer a secure
         communication channel, we'll use the http version of the URL and have
         added "earthquake.usgs.gov" to the "NSExceptionDomains" value in the
         app's Info.plist file. When you communicate with your own servers,
         or when the services you use offer secure communication options, you
         should always prefer to use https.
         */
        k.apiWeatherDownloadURL
        
        let url = NSURL(string: String(format: k.apiWeatherDownloadURL, String(location.coordinate.latitude), String(location.coordinate.longitude), k.apiKey))!
        print("URL:\(url)")
        
        let task = NSURLSession.sharedSession().downloadTaskWithURL(url) { url, response, error in
            self.downloadFinished(url, response: response as? NSHTTPURLResponse, error: error)
        }
        
        let taskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(host: url)
        taskOperation.addCondition(reachabilityCondition)
        
        let networkObserver = NetworkObserver()
        taskOperation.addObserver(networkObserver)
        
        addOperation(taskOperation)
    }
    
    func downloadFinished(url: NSURL?, response: NSHTTPURLResponse?, error: NSError?) {
        if let localURL = url {
            do {
                /*
                 If we already have a file at this location, just delete it.
                 Also, swallow the error, because we don't really care about it.
                 */
                try NSFileManager.defaultManager().removeItemAtURL(cacheFile)
            }
            catch { }
            
            do {
                try NSFileManager.defaultManager().moveItemAtURL(localURL, toURL: cacheFile)
            }
            catch let error as NSError {
                aggregateError(error)
            }
            
        }
        else if let error = error {
            aggregateError(error)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }
}
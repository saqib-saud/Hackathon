//
//  WeatherListTableViewController.swift
//  WeatherMan
//
//  Created by Saqib Saud on 4/15/16.
//  Copyright © 2016 Saqib Saud. All rights reserved.
//

import UIKit
import CoreData

class WeatherListTableViewController: UITableViewController {

    var fetchedResultsController: NSFetchedResultsController?
    
    let operationQueue = OperationQueue()
    
    func setup() {
        let refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: Selector("startRefreshing:"), forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.registerNib(WeatherTableViewCell.cellNib(), forCellReuseIdentifier: WeatherTableViewCell.cellIdentifier())
    }
    //Mark: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        let operation = LoadModelOperation { context in
            // Now that we have a context, build our `FetchedResultsController`.
            dispatch_async(dispatch_get_main_queue()) {
                let request = NSFetchRequest(entityName: Weather.entityName)
                
                request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
                
                request.fetchLimit = 100
                
                let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                
                self.fetchedResultsController = controller
                
                self.updateUI()
            }
        }
        
        operationQueue.addOperation(operation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[section]
        
        return section?.numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(WeatherTableViewCell.cellIdentifier(), forIndexPath: indexPath) as! WeatherTableViewCell
        
        if let weather = fetchedResultsController?.objectAtIndexPath(indexPath) as? Weather {
            cell.configure(weather)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }

    //MARK: - Network Requests
    @IBAction func startRefreshing(sender: UIRefreshControl) {
        getWeatherUpdates()
    }
    
    private func getWeatherUpdates(userInitiated: Bool = true) {
        if let context = fetchedResultsController?.managedObjectContext {
            let getWeatherDataOperation = GetWeatherDataOperation(context: context) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshControl?.endRefreshing()
                    self.updateUI()
                }
            }
            
            getWeatherDataOperation.userInitiated = userInitiated
            operationQueue.addOperation(getWeatherDataOperation)
        }
        else {
            /*
             We don't have a context to operate on, so wait a bit and just make
             the refresh control end.
             */
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue()) {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func updateUI() {
        do {
            try fetchedResultsController?.performFetch()
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
        
        self.tableView.reloadData()
    }

}

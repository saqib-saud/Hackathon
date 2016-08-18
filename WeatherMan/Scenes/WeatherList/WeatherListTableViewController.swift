//
//  WeatherListTableViewController.swift
//  WeatherMan
//
//  Created by Saqib Saud on 4/15/16.
//  Copyright © 2016 Saqib Saud. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import DZNSegmentedControl

class WeatherListTableViewController: UITableViewController, DZNSegmentedControlDelegate {

    var webserviceType:WebServiceConstants = WebServiceConstants.Flights
    lazy var dnzControll:DZNSegmentedControl? = {
        
        let controller = DZNSegmentedControl(items:["Flights", "Trains", "Buses"])
        controller.delegate = self
        controller.selectedSegmentIndex = 0
        controller.bouncySelectionIndicator = false
        controller.showsCount = false
        controller.height = 60.0
        controller.addTarget(self, action:#selector(didChangeSegment), forControlEvents: UIControlEvents.ValueChanged)
        return controller
    }()
    var sortAscend:Bool = true
    var fetchedResultsController: NSFetchedResultsController?
    
    let operationQueue = OperationQueue()
    
    func setup() {
//        let refreshControl = UIRefreshControl()
//        self.tableView.addSubview(refreshControl)
//        refreshControl.addTarget(self, action: Selector("startRefreshing:"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.tableHeaderView = self.dnzControll;
        self.tableView.registerNib(WeatherTableViewCell.cellNib(), forCellReuseIdentifier: WeatherTableViewCell.cellIdentifier())
    }
    //Mark: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.toolbarHidden = false
        setup()
        loadData()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didAskedForSorting(sender: UIBarButtonItem) {
        sortAscend = !sortAscend
        loadData()
    }
    // MARK: - DZNSegmentedControl Delegate
    @objc func didChangeSegment(segmentControl:DZNSegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            webserviceType = .Flights
            loadData()
        case 1:
            webserviceType = .Trains
            loadData()
        case 2:
            webserviceType = .Buses
            loadData()
        default:
            loadData()

        }
    }
    func positionForBar(view:UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.Any
    }
    
    func positionForSelectionIndicator(view:UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.Any
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
        
        if let weather = fetchedResultsController?.objectAtIndexPath(indexPath) as? Transit {
            cell.configure(weather)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }

    //MARK: - Operation
    
    func loadData() {
        let operation = LoadModelOperation { context in
            // Now that we have a context, build our `FetchedResultsController`.
            dispatch_async(dispatch_get_main_queue()) {
                let request = NSFetchRequest(entityName: Transit.entityName)
                request.predicate = NSPredicate(format: "self.transitType = %@", self.webserviceType.rawValue)
                request.sortDescriptors = [NSSortDescriptor(key: "transitId", ascending: self.sortAscend)]
                
                request.fetchLimit = 100
                
                let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                
                self.fetchedResultsController = controller
                self.getWeatherUpdates(self.webserviceType)
                self.updateUI()
            }
        }
        
        operationQueue.addOperation(operation)
    }
    //MARK: - Network Requests
    @IBAction func startRefreshing(sender: UIRefreshControl) {
        self.getWeatherUpdates(WebServiceConstants.Flights)
    }
    
    private func getWeatherUpdates(webService:WebServiceConstants, userInitiated: Bool = false) {
        if let context = fetchedResultsController?.managedObjectContext {
            let getWeatherDataOperation = GetWeatherDataOperation(webservice: webService, context: context) {
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

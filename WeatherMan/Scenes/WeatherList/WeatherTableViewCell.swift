//
//  WeatherTableViewCell.swift
//  WeatherMan
//
//  Created by Saqib Saud on 4/15/16.
//  Copyright © 2016 Saqib Saud. All rights reserved.
//

import UIKit

//This protocol is mandatory for every cell.
protocol TableViewCellProtocol {
    static func cellIdentifier() -> String
    static func cellNib() -> UINib
}
class WeatherTableViewCell: UITableViewCell, TableViewCellProtocol {
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var minTemperatureLabel: UILabel!
    @IBOutlet var maxTemperatureLabel: UILabel!
    @IBOutlet var weatherDescriptionLabel: UILabel!
    @IBOutlet var weatherIcon: UIImageView!
    
    // MARK: Configuration
    
    func configure(weather: Weather) {
        dayLabel.text = Weather.timestampFormatter.stringFromDate(weather.date!)
        
        minTemperatureLabel.text = String(weather.minTemp)
        maxTemperatureLabel.text = String(weather.maxTemp)
        weatherDescriptionLabel.text = weather.weatherDescription
        weatherIcon.image = UIImage(named: weather.weatherIcon!)
    }
    
    static func cellIdentifier() -> String {
        return String(self)
    }
    
    static func cellNib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
}

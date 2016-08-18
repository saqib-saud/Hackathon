//
//  WeatherTableViewCell.swift
//  WeatherMan
//
//  Created by Saqib Saud on 4/15/16.
//  Copyright © 2016 Saqib Saud. All rights reserved.
//

import UIKit
import SDWebImage
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
    
    func configure(weather: Transit) {
        dayLabel.text = String(weather.departureTime! + " - " + weather.arrivalTime!)
        minTemperatureLabel.text = String("€ " + weather.priceInEuros!)
//        weatherDescriptionLabel.text = weather.weatherDescription
//        print(weather.providerLogo!.stringByReplacingOccurrencesOfString("{size}", withString: "63"))
        weatherIcon.sd_setImageWithURL(NSURL(string: weather.providerLogo!.stringByReplacingOccurrencesOfString("{size}", withString: "63")))

    }
    
    static func cellIdentifier() -> String {
        return String(self)
    }
    
    static func cellNib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
}

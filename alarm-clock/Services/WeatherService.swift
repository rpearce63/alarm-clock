//
//  WeatherService.swift
//  alarm-clock
//
//  Created by Helen Pearce on 4/28/18.
//  Copyright © 2018 Rick Pearce. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeatherService {
    static let instance = WeatherService()
    
    func getWeather() -> JSON {
        var current : JSON?;
        return Alamofire.request(URL(string: "https://api.darksky.net/forecast/719e207be3ba45829aeadc5594f8d363/37.8267,-122.4233")!)
            .validate()
            .responseJSON { (responseData) in
                
                //                print("Request: \(response.request)")
                //                print("Response: \(response.response)")
                //                print("Error: \(response.error)")
                
                if((responseData.result.value) != nil) {
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    current =  swiftyJsonVar
                    
                }
                return current
        }
        
    }
    
}



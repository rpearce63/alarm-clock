//
//  WeatherService.swift
//  alarm-clock
//
//  Created by Rick on 5/27/19.
//  Copyright © 2019 Rick Pearce. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherService: NSObject, CLLocationManagerDelegate {
    static let instance = WeatherService()
    
    let locationManager = CLLocationManager()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var city: String!
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            //getCity(lat: latitude, long: longitude)
            lookUpCurrentLocation { (location) in
                self.city = location?.locality ?? ""
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location update failed: \(error.localizedDescription)")
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(
                lastLocation,
                completionHandler: { (placemarks, error) in
                    if error == nil {
                        let firstLocation = placemarks?[0]
                        completionHandler(firstLocation)
                    }
                    else {
                        // An error occurred during geocoding.
                        completionHandler(nil)
                    }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    
    func getWeather(completion: @escaping (JSON) -> Void ) {
        locationManager.requestLocation()
        Alamofire.request( "https://api.darksky.net/forecast/719e207be3ba45829aeadc5594f8d363/\(latitude),\(longitude)")
            .validate()
            .responseJSON { (responseData) in
                //print(responseData)
                if((responseData.result.value) != nil) {
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    completion( swiftyJsonVar)
                }
        }
        
        
    }
}

//
//  ViewController.swift
//  Weather
//
//  Created by Николай Соломатин on 10.05.2020.
//  Copyright © 2020 Николай Соломатин. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    
    let gradientLayer = CAGradientLayer()
    var actIndicator: NVActivityIndicatorView!
    
    var apiKey: String = " "
    var lat = 55.751805
    var lon = 37.618443
    let locationManager = CLLocationManager()
    
    struct WeatherConditions {
        var tempC: String
        var windSpeed: String
        var windDir: String
        var pressure: String
        var name: String
        var isDay: String
        var location: String
        var code: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(gradientLayer)
        // Prepare indicator
        let actIndicatorSize: CGFloat = 180.0
        let actIndicatorFrame = CGRect(x: (view.frame.width - actIndicatorSize) / 2, y: 140.0, width: actIndicatorSize, height: actIndicatorSize)
        actIndicator = NVActivityIndicatorView(frame: actIndicatorFrame, type: .circleStrokeSpin, color: UIColor.white, padding: 50.0)
        actIndicator.backgroundColor = .clear

        // Add Day
        displayDayOfWeek()
        // Add activity indicator
        view.addSubview(actIndicator)
        actIndicator.startAnimating()
        // Ask permission to get device location
        locationManager.requestWhenInUseAuthorization()
        // Start find location
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setDayBackground()
        apiKey = getWeatherApiKey()
        print("API-key=\(apiKey)")
    }

    
    /// Location update callback
    /// - Parameters:
    ///   - manager: Location manager
    ///   - locations: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        print("Location \(lat), \(lon)")
        requestCurrentWeather()
    }
    
    
    /// Reguests current weather via API
    func requestCurrentWeather(){
        Alamofire.request("http://api.weatherstack.com/current?access_key=\(apiKey)&query=\(lat),\(lon)").responseJSON {
            response in
            if let responseString = response.result.value {
                // Response
                let jsonResponse = JSON(responseString)
                // Response -> Current
                let jsonCurrent = jsonResponse["current"]
                // Response -> Current ->
                let jsonTemp = jsonCurrent["temperature"]
                let jsonDescription = jsonCurrent["weather_descriptions"].array![0]
                let jsonIsDay = jsonCurrent["is_day"]
                let jsonWindDir = jsonCurrent["wind_dir"]
                let jsonWindSpeed = jsonCurrent["wind_speed"]
                let jsonPressure = jsonCurrent["pressure"]
                let jsonWCode = jsonCurrent["weather_code"]
                // Response -> Location
                let jsonLocation = jsonResponse["location"]
                let jsonCountry = jsonLocation["country"]
                let jsonRegion = jsonLocation["region"]
                let jsonName = jsonLocation["name"]
                // Location name
                let location = jsonCountry.stringValue + ", " + jsonRegion.stringValue + ", " + jsonName.stringValue
                // Form conditions
                let weather = WeatherConditions(
                    tempC: jsonTemp.stringValue,
                    windSpeed: jsonWindSpeed.stringValue,
                    windDir: jsonWindDir.stringValue,
                    pressure: jsonPressure.stringValue,
                    name: jsonDescription.stringValue,
                    isDay: jsonIsDay.stringValue,
                    location: location,
                    code: jsonWCode.stringValue)
                
                print(jsonCurrent)
                self.displayCurrentWeather(weather: weather)
            }
        }
    }
    
    /// Shows current weather conditions on screen
    /// - Parameter weather: Structure of weather conditions
    func displayCurrentWeather(weather: WeatherConditions){
        tempLabel.text = weather.tempC
        locationLabel.text = weather.location
        weatherLabel.text = weather.name
        if weather.isDay == "yes" {
            setDayBackground()
        } else {
            setNightBackground()
        }
        actIndicator.stopAnimating()
        switch weather.code{
        case "113", "116", "308", "389":
            conditionImageView.image = UIImage(named: weather.code)
        default:
            conditionImageView.image = UIImage(named: "defaultIcon")
        }
        
    }
    
    /// Get and display day of week
    func displayDayOfWeek(){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        self.dayLabel.text = dateFormatter.string(from: date)
    }
    
    /// This function sets background color for day time
    func setDayBackground(){
        let topColor = UIColor(red: 50.0/255.0, green: 220.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        let botColor = UIColor(red: 20.0/255.0, green: 120.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, botColor]
    }
    
    /// This function sets background color for night time
    func setNightBackground(){
        let topColor = UIColor(red: 20.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0).cgColor
        let botColor = UIColor(red: 0.0/255.0, green: 80.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, botColor]
    }

    
    /// This function gets API-key from file APIKeys.plist
    /// - Returns: API-key for weatherstack.com
    func getWeatherApiKey() -> String {
        let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist")!
        let parameters = NSDictionary(contentsOfFile:filePath)
        let apiKey = parameters!["weatherApiKey"]! as! String
        return apiKey
    }
}


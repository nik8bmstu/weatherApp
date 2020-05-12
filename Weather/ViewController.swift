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
    
    var apiKey: String!
    var lat = 55.751805
    var lon = 37.618443
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(gradientLayer)
        // Prepare indicator
        let actIndicatorSize: CGFloat = 180.0
        let actIndicatorFrame = CGRect(x: (view.frame.width - actIndicatorSize) / 2, y: 140.0, width: actIndicatorSize, height: actIndicatorSize)
        actIndicator = NVActivityIndicatorView(frame: actIndicatorFrame, type: .circleStrokeSpin, color: UIColor.white, padding: 50.0)
        actIndicator.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        // Add Day
        displayDayOfWeek()
        // Add activity indicator
        view.addSubview(actIndicator)
        // Ask permission to get device location
        locationManager.requestWhenInUseAuthorization()
        // Start find location
        if CLLocationManager.locationServicesEnabled(){
            actIndicator.startAnimating()
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        print("Location \(lat), \(lon)")
        requestCurrentWeather()
        self.actIndicator.stopAnimating()
    }
    
    func requestCurrentWeather(){
        Alamofire.request("http://api.weatherstack.com/current?access_key=\(apiKey)&query=\(lat),\(lon)").responseJSON {
            response in
            if let responseString = response.result.value {
                let jsonResponse = JSON(responseString)
                print(jsonResponse)
            }
        }
    }
    
    /// Get and display day of week
    func displayDayOfWeek(){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
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


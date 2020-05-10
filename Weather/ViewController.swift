//
//  ViewController.swift
//  Weather
//
//  Created by Николай Соломатин on 10.05.2020.
//  Copyright © 2020 Николай Соломатин. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(gradientLayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setDayBackground()
    }

    func setDayBackground(){
        let topColor = UIColor(red: 50.0/255.0, green: 220.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        let botColor = UIColor(red: 20.0/255.0, green: 120.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, botColor]
    }
    
    func setNightBackground(){
        let topColor = UIColor(red: 20.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0).cgColor
        let botColor = UIColor(red: 0.0/255.0, green: 80.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, botColor]
    }

}


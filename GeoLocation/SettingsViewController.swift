//
//  SettingsViewController.swift
//  GeoLocation
//
//  Created by Vinoth Varatharajan on 23/12/2019.
//  Copyright © 2019 Vin. All rights reserved.
//

import UIKit
import CoreLocation

protocol ConfigureLocationDelegate {
    func updateLocation(lat : String, long : String)
}

class SettingsViewController: UIViewController {
    
    //MARK: - IBOutlet Variable
    @IBOutlet weak var latField     : UITextField!
    @IBOutlet weak var longField    : UITextField!

    //MARK: -  Variable declaration
    var delegate : ConfigureLocationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //Save textField Value
        delegate?.updateLocation(lat: latField.text!, long: longField.text!)
    }
    
    //MARK: - Setup View
    private func setUpView() {
        title = "Configure Location"
        
        let defaults    = UserDefaults.standard
        latField.text   = "\(defaults.double(forKey: "Lat"))"
        longField.text  = "\(defaults.double(forKey: "Long"))"
    }
    
    //MARK: - UIButton Action
    @IBAction func longAction(_ sender: Any) {
        
        if isCoordinateValid(latitude: (latField.text! as NSString).doubleValue, longitude: (longField.text! as NSString).doubleValue) {
            delegate?.updateLocation(lat: latField.text!, long: longField.text!)
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Invalid coordinates", message:"",preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func setAction(_ sender: Any) {
        let defaults    = UserDefaults.standard
        latField.text   = "\(defaults.double(forKey: "current_lat"))"
        longField.text  = "\(defaults.double(forKey: "current_long"))"
    }

    //MARK: - Validate Coordinates

    func isCoordinateValid(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Bool {
        guard latitude != 0, longitude != 0, CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) else {
            return false
        }
        return true
    }
}

extension UITextField {

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.select(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:))
    }
}

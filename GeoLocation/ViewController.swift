//
//  ViewController.swift
//  GeoLocation
//
//  Created by Vinoth Varatharajan on 23/12/2019.
//  Copyright © 2019 Vin. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import NetworkExtension
import Reachability

class ViewController: UIViewController {
    
    //MARK: - IBOutlet Variable
    @IBOutlet weak var determineRegionLabel     : UILabel!
    @IBOutlet weak var wifiNameLabel            : UILabel!
    @IBOutlet weak var wifiIndicatorLabel       : UILabel!
    
    //MARK: - Private Valriable declaration
    private let locationMgr         = CLLocationManager()
    private let reachability        = try! Reachability()
    private let wifiName            = "TP-Link_5378"
    private var lattitude           : Double?
    private var longtitude          : Double?
    private var withinLocation      : Bool = false
    private var connectedToAuthWifi : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        configureLocationManager()
    }
    
    //MARK: - Configure CLLocationManager
    private func configureLocationManager() {
        locationMgr.delegate = self
        
        let defaults = UserDefaults.standard
        
        if defaults.double(forKey: "Lat") > 0 {
            lattitude = defaults.double(forKey: "Lat")
        }
        if defaults.double(forKey: "Long") > 0 {
            longtitude = defaults.double(forKey: "Long")
        }
        
        if let _ = lattitude, let _ = longtitude {
            setRegion()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        // Do any additional setup after loading the view.
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationMgr.requestWhenInUseAuthorization()
            locationMgr.requestAlwaysAuthorization()
            return
            
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
            
        case .authorizedAlways, .authorizedWhenInUse: setWifiStatus()
        @unknown default: break
        }
        
        reachability.whenReachable = { reachability in
            self.setWifiStatus()
        }
        
        reachability.whenUnreachable = { _ in
            self.setWifiStatus()
        }

    }
    
    //MARK: - Setup Region
    private func setRegion() {
        guard let _lat = lattitude, let _long = longtitude else {
            let alert = UIAlertController(title: "Invalid Location", message: "Please enter a valid Lat and Long", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.set(_lat, forKey: "Lat")
        defaults.set(_long, forKey: "Long")
        defaults.synchronize()
        
        let geofenceRegionCenter = CLLocationCoordinate2DMake(_lat, _long)
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: 100,
                                              identifier: "UniqueIdentifier")
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        locationMgr.delegate = self
        locationMgr.startMonitoring(for: geofenceRegion)
    }
    
    //MARK: - Set Wifi status
    func setWifiStatus() {
        if let ssid = getSSID() {
            wifiNameLabel.text = ssid
            wifiIndicatorLabel.isHidden = false
            connectedToAuthWifi = true
        }
        else {
            wifiNameLabel.text = "Not connected to Wifi"
            wifiIndicatorLabel.isHidden = true
            connectedToAuthWifi = false
        }
        
        updateStatus()
    }

    //MARK: - Get SSID
    func getSSID() -> String? {
        guard let interface = (CNCopySupportedInterfaces() as? [String])?.first,
            let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
            let ssid = unsafeInterfaceData["SSID"] as? String else{
                return nil
        }
        return ssid
    }
    
    //MARK: - Wifi Status Observer
    @objc func observer() {
        setWifiStatus()
    }

    //MARK: - UIButton Action
    @IBAction func configureAction(_ sender: Any) {
        
    }
    
    //MARK: - Update User Region Status
    func updateStatus() {
        
        if connectedToAuthWifi {
            determineRegionLabel.text = "Yes beacuse you are connected to Wifi"
        }
        else if let _ = lattitude, let _ = longtitude {
            
            if withinLocation {
                determineRegionLabel.text = "Yes beacuse you are within the authorized region"
            }
            else {
                determineRegionLabel.text = "No beacuse you are not connected to Wifi and not within the authorized region"
            }
        }
        else {
            determineRegionLabel.text = "Location not configured."
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            locationMgr.requestWhenInUseAuthorization()
            locationMgr.requestAlwaysAuthorization()
            return
            
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
            
        case .authorizedAlways, .authorizedWhenInUse: setWifiStatus()
        @unknown default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        switch state {
            
        case .unknown:
            withinLocation = false
        case .inside:
            withinLocation = true
        case .outside:
            withinLocation = false
        }
        
        updateStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        withinLocation = true
        updateStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        withinLocation = false
        updateStatus()
    }
}

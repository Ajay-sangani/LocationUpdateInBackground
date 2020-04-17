//
//  LocationTracker.swift
//  Ajay Sangani
//
//  Created by Ajay Sangani on 19/07/18.
//  Copyright (c) 2020 Ajay Sangani. All rights reserved.
//


import Foundation
import UIKit
import CoreLocation

let ACCURACY = "theAccuracy"

protocol CurruntLocationDelegate {
  func GetCurruntLocation(Latitude:Double,Longitude:Double)
}

class LocationTracker : NSObject, UIAlertViewDelegate {
  
  //------------------------------------------
  //MARK: - Class Variables -
  var shareModel : LocationShareModel?
  var locationManager : CLLocationManager = CLLocationManager()
  
  //------------------------------------------
  //MARK: - View Life Cycle Methods -
  override init() {
    super.init()
    self.shareModel = LocationShareModel()
    self.shareModel!.myLocationArray = NSMutableArray()
    locationManager = LocationTracker.sharedLocationManager()!
  }
  
  class func sharedLocationManager()->CLLocationManager? {
    
    struct Static {
      static var _locationManager : CLLocationManager?
    }
    
    objc_sync_enter(self)
    
    if Static._locationManager == nil {
      Static._locationManager = CLLocationManager()
      Static._locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
      Static._locationManager?.allowsBackgroundLocationUpdates = false
      Static._locationManager?.pausesLocationUpdatesAutomatically = false
    }
    objc_sync_exit(self)
    return Static._locationManager!
  }
  
  static let shared: LocationTracker = {
    let instance = LocationTracker()
    return instance
  }()
  
  func initLocation(isOneTime: Bool = false) {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter =  kCLDistanceFilterNone
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = true
    locationManager.requestAlwaysAuthorization()
    
    if isOneTime {
      locationManager.requestLocation()
    } else {
      locationManager.startUpdatingLocation()
    }
  }
  
  // MARK: Application in background
  @objc func applicationEnterBackground() {
    initLocation()
    self.shareModel!.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager
    self.shareModel?.bgTask?.endAllBackgroundTasks()//endBackgroundTask()
    _ = self.shareModel?.bgTask?.beginNewBackgroundTask()
  }
  
  func restartLocationUpdates() {
    print("restartLocationUpdates\n")
    if self.shareModel?.timer != nil {
      self.shareModel?.timer?.invalidate()
      self.shareModel?.timer = nil
    }
    initLocation()
  }
  
  //MARK: Stop the locationManager
  func stopLocationDelayBy10Seconds() {
    locationManager.stopUpdatingLocation()
    print("locationManager stop Updating after 10 seconds\n")
  }
  
  func stopLocationTracking() {
    print("stopLocationTracking\n")
    
    if self.shareModel!.timer != nil {
      self.shareModel!.timer!.invalidate()
      self.shareModel!.timer = nil
    }
    
    locationManager.stopUpdatingLocation()
    NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
  }
}

//MARK: - Location Manager Delegate methods -
extension LocationTracker: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let locationArray = locations as NSArray
    let locationObj = locationArray.lastObject as! CLLocation
    let coord = locationObj.coordinate
    
    if UIApplication.shared.applicationState == UIApplication.State.background {
      self.shareModel?.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager
      self.shareModel?.bgTask?.endAllBackgroundTasks()
      _ = self.shareModel?.bgTask?.beginNewBackgroundTask()
    } else {
      appDelegate.LatitudeGPS = String(format: "%.10f", coord.latitude)
      appDelegate.LongitudeGPS = String(format: "%.10f", coord.longitude)
      appDelegate.Altitude = String(format: "%.10f", manager.location!.altitude)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
    switch (error._code) {
    case CLError.network.rawValue:
      let alert : UIAlertView = UIAlertView(title: "Network Error", message: "Please check your network connection.", delegate: self, cancelButtonTitle: "OK")
      alert.show()
      break
    case CLError.denied.rawValue:
      //let alert : UIAlertView = UIAlertView(title: "Location Service Error", message: "Location services has been denied.", delegate: self, cancelButtonTitle: "OK")
      //alert.show()
      //Please check your network connection.
      break
    default:
      break
    }
  }
}


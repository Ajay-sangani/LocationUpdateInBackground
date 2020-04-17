//
//  AppDelegate.swift
//  UpdateLocationInBackground
//
//  Created by Aj's Mac on 16/04/20.
//  Copyright © 2020 Aj's Mac. All rights reserved.
//

import UIKit
import CoreLocation

var appDelegate : AppDelegate {
  get {
    return UIApplication.shared.delegate as! AppDelegate
  }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let locationManager = CLLocationManager()
  var currentLoc: CLLocation!
  var LatitudeGPS = String()
  var LongitudeGPS = String()
  var Altitude = String()
  var bgtimer = Timer()
  var count = 0
  var shareModel : LocationShareModel?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    self.shareModel = LocationShareModel()
    self.shareModel!.myLocationArray = NSMutableArray()
    self.StartupdateLocation()
    
    /*let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
    let navigationController = UINavigationController(rootViewController: newViewController)
    window!.rootViewController = navigationController
    self.window?.makeKeyAndVisible()*/
    return true
  }
  
  func StartupdateLocation() {
    locationManager.delegate = self
    locationManager.startUpdatingLocation()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.requestAlwaysAuthorization()
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = true
    
    if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
      CLLocationManager.authorizationStatus() == .authorizedAlways) {
      currentLoc = locationManager.location
    }
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    UIApplication.shared.applicationIconBadgeNumber = 0
    appDelegate.shareModel?.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager
    appDelegate.shareModel?.bgTask?.endAllBackgroundTasks()
    appDelegate.shareModel?.bgTask?.removeAllTimers()
    appDelegate.bgtimer.invalidate()
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    appDelegate.shareModel!.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager
    appDelegate.shareModel?.bgTask?.endAllBackgroundTasks()//endBackgroundTask()
    _ = appDelegate.shareModel?.bgTask?.beginNewBackgroundTask()
    
    appDelegate.doBackgroundTask()
  }
}

extension AppDelegate: CLLocationManagerDelegate {
  func doBackgroundTask() {
    DispatchQueue.global(qos: .background).async {
      self.bgtimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.bgtimer(timer:)), userInfo: nil, repeats: true)
      RunLoop.current.add(self.bgtimer, forMode: .tracking)
      RunLoop.current.run()
      self.updateLocation()
    }
  }
  
  @objc func bgtimer(timer:Timer!){
    // MARK: Integrate API Call
  }
  
  func updateLocation() {
    locationManager.startUpdatingLocation()
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    count = count + 1
    LatitudeGPS = String(format: "%.10f", manager.location!.coordinate.latitude)
    LongitudeGPS = String(format: "%.10f", manager.location!.coordinate.longitude)
    Altitude = String(format: "%.3f", manager.location!.altitude)
    
    if UIApplication.shared.applicationState == UIApplication.State.background {
      appDelegate.shareModel?.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager
      appDelegate.shareModel?.bgTask?.endAllBackgroundTasks()
      _ = appDelegate.shareModel?.bgTask?.beginNewBackgroundTask()
    } else {
      appDelegate.shareModel?.bgTask?.endAllBackgroundTasks()
    }
  }
}

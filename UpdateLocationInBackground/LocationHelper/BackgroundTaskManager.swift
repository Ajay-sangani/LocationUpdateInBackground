//
//  BackgroundTaskManager.swift
//  Ajay Sangani
//
//  Created by Ajay Sangani on 19/07/18.
//  Copyright (c) 2020 Ajay Sangani. All rights reserved.
//


import Foundation
import UIKit
import CoreLocation

class BackgroundTaskManager : NSObject {
  
  var bgTaskIdList : NSMutableArray?
  var masterTaskId : UIBackgroundTaskIdentifier?
  var locationTimer : Timer?
  
  override init() {
    super.init()
    self.bgTaskIdList = NSMutableArray()
    self.masterTaskId = UIBackgroundTaskIdentifier.invalid
  }
  
  class var sharedBackgroundTaskManager: BackgroundTaskManager {
    struct Static {
      static var sharedBGTaskManager: BackgroundTaskManager? = BackgroundTaskManager()
      static var onceToken = {0}()
    }
    _ = Static.onceToken
    return Static.sharedBGTaskManager!
  }
  
  func beginNewBackgroundTask() -> UIBackgroundTaskIdentifier? {
    
    let application : UIApplication = UIApplication.shared
    var bgTaskId : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    if application.responds(to: #selector(UIApplication.beginBackgroundTask)) {
      print("RESPONDS TO SELECTOR")
      bgTaskId = application.beginBackgroundTask(expirationHandler: {
        print("background task \(bgTaskId.hashValue) expired\n")
      })
    }
    
    let state = UIApplication.shared.applicationState
    if state == .background {
      if locationTimer == nil {
        locationTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.updateLocation), userInfo: nil, repeats: true)
      }
    }
    
    if self.masterTaskId == UIBackgroundTaskIdentifier.invalid {
      self.masterTaskId = bgTaskId
      print("started master task \(self.masterTaskId?.hashValue ?? 0)\n")
    } else {
      // add this ID to our list
      print("started background task \(bgTaskId.hashValue)\n")
      self.bgTaskIdList!.add(bgTaskId)
      //self.endBackgr
    }
    return bgTaskId
  }
  
  @objc func updateLocation() {
  }
  
  @objc func endBackgroundTask(){
    self.drainBGTaskList(all: false)
  }
  
  func endAllBackgroundTasks() {
    self.drainBGTaskList(all: true)
  }
  
  func removeAllTimers(){
    if locationTimer != nil {
      locationTimer?.invalidate()
      locationTimer = nil
    }
  }
  
  func drainBGTaskList(all:Bool) {
    //mark end of each of our background task
    let application: UIApplication = UIApplication.shared
    
    //endBackgroundTask
    let _ : Selector = #selector(BackgroundTaskManager.endBackgroundTask)
    let count : Int = self.bgTaskIdList!.count
    for _ in (all==true ? 0:1) ..< count {
      let bgTaskId : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: self.bgTaskIdList!.object(at: 0) as! Int)
      application.endBackgroundTask(bgTaskId)
      self.bgTaskIdList!.removeObject(at: 0)
    }
    
    if self.bgTaskIdList!.count > 0 {
      print("kept background task id \(self.bgTaskIdList!.object(at: 0))\n")
    }
    if all == true {
      print("no more background tasks running\n")
      application.endBackgroundTask(self.masterTaskId!)
      self.masterTaskId = UIBackgroundTaskIdentifier.invalid
    } else {
      print("kept master background task id \(self.masterTaskId?.hashValue ?? 0)\n")
    }
  }
}

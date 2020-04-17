//
//  LocationShareModel.swift
//  Ajay Sangani
//
//  Created by Ajay Sangani on 19/07/18.
//  Copyright (c) 2020 Ajay Sangani. All rights reserved.
//

import Foundation
import UIKit

class LocationShareModel : NSObject {
  
  var timer : Timer?
  var delay10Seconds : Timer?
  var bgTask : BackgroundTaskManager?
  var myLocationArray : NSMutableArray?
  
  class var sharedModel: LocationShareModel {
    struct Static {
      static var instance: LocationShareModel?
      static var token = {0}()
    }
    _ = Static.token
    return Static.instance!
  }
}

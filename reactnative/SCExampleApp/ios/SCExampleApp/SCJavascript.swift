//
//  SCJavascript.swift
//  SCExampleApp
//
//  Created by Frank Rowe on 4/21/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import Foundation
  
@objc(SCJavascript)
class SCJavascript: NSObject {

  var sc: SpatialConnect!
  var bridge: RCTBridge!

  override init() {
    let del = UIApplication.sharedApplication().delegate as! AppDelegate
    self.sc = del.spatialConnectSharedInstance()
    super.init()
  }
  
  @objc func startGPS() -> Void {
    self.setupBridge()
  }

  func setupBridge() {
    self.sc.manager.sensorService.enableGPS()
    self.sc.manager.sensorService.lastKnown.subscribeNext {(next:AnyObject!) -> () in
      if let loc = next as? CLLocation {
        NSLog("Bridge: %@", self.bridge);
        let lat:Double = loc.coordinate.latitude
        let lon:Double = loc.coordinate.longitude
        NSLog("Lat: %@", lat);
        self.bridge.eventDispatcher.sendAppEventWithName("lastKnown", body: [ "lat": lat, "lon": lon ])
      }
    }
  }
  
}
//
//  TLIAnalyticsTracker.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Mixpanel

class TLIAnalyticsTracker: NSObject {
    
    class func createAlias(userID:String) {
        let mixpanel:Mixpanel = Mixpanel.sharedInstance()
        mixpanel.createAlias(userID, forDistinctID: mixpanel.distinctId)
        mixpanel.identify(mixpanel.distinctId)
        
        let params = ["id": userID, "$name": userID, "$email": "\(userID)@tinylogapp.com"]
        
        mixpanel.registerSuperProperties(params as [NSObject : AnyObject])
        mixpanel.people.set(params as [NSObject : AnyObject])
    }
    
    class func trackMixpanelEvent(event:String!, properties:[String: String]! ) {
        //var tmpProperties: Dictionary <String, String> = [String: String]()
        let mixpanel:Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track(event, properties: properties)
    }
}

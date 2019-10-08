//
//  CFMessagingService.swift
//  CustomFit
//
//  Created by Bharath R on 28/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import FirebaseMessaging

open class CFMessagingService: NSObject {
    
    static let shared = CFMessagingService()
    
    private override init() {
        
    }
    
}

extension CFMessagingService: MessagingDelegate {
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
    }
    
    public func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        if remoteMessage.appData.count > 0 && (CustomFit.shared.isCFMessage(message: remoteMessage.appData as? [String : String])) {
            CustomFit.shared.handleCFMessage(app: UIApplication.shared, message: remoteMessage.appData as! [String : String])
        }
    }
    
}

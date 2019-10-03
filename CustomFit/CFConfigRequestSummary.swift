//
//  CFConfigRequestSummary.swift
//  CustomFit
//
//  Created by Rajtharan G on 22/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

struct CFConfigRequestSummary: Codable {
    
    private var configId: String?
    private var version: Int?
    private var requestedTime: String?
    private var variationName: String?
    private var userId: String?
    private var cfUserId: String?
    private var eventType: CFEventType?
    private var experienceId: String?
    private var behaviour: String?
    
    enum CodingKeys: String, CodingKey {
        case configId = "config_id"
        case version
        case requestedTime = "requested_time"
        case variationName = "variation_name"
        case userId = "user_customer_id"
        case cfUserId = "user_id"
        case eventType = "event_type"
        case experienceId = "experience_id"
        case behaviour 
    }
    
    init(config: CFConfig) {
        self.configId = config.configId
        self.eventType = CFEventType.configSummary
        self.requestedTime = CFUtil.getSupportedDateFormat().string(from: Date())
        self.userId =  CFSharedPreferences.shared.getUser()?.id
        self.cfUserId = CFSharedPreferences.shared.getUser()?.cfUserId
        self.version = config.version
        self.variationName = config.variationName
        self.behaviour = config.experienceBehaviourResponse?.behaviour
        self.experienceId = config.experienceBehaviourResponse?.experienceId
    }
    
}

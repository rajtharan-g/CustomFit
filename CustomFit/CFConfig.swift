//
//  CFconfig.swift
//  CustomFit
//
//  Created by Rajtharan G on 21/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

struct CFConfig: Codable, Equatable {
    
    var configId: String?
    var userId: String?
    var customerId: String?
    var variation: JSON?
    var version: Int?
    var variationName: String?
    var variationDataType: CFVariationDataType?
    var experienceBehaviourResponse: CFExperienceBehaviourResponse?
    
    enum CodingKeys: String, CodingKey {
        case configId = "config_id"
        case userId = "user_id"
        case customerId = "config_customer_id"
        case variation
        case version
        case variationName = "variation_name"
        case variationDataType = "variation_data_type"
        case experienceBehaviourResponse = "experience_behaviour_response"
    }
    
    static func == (lhs: CFConfig, rhs: CFConfig) -> Bool {
        return lhs.configId == rhs.configId
    }

}

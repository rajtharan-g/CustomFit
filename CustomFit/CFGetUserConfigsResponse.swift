//
//  CFGetUserConfigsResponse.swift
//  CustomFit
//
//  Created by Rajtharan G on 20/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

struct CFGetUserConfigsResponse: Codable {
    
    var cfUserId: String?
    var id: String?
    var configs: Dictionary<String, CFConfig>?
    
    enum CodingKeys: String, CodingKey {
        case cfUserId = "user_id"
        case id = "user_customer_id"
        case configs
    }

}

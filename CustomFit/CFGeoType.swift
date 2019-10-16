//
//  CFGeoType.swift
//  CustomFit
//
//  Created by Rajtharan G on 15/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

public struct CFGeoType: Codable, Equatable {
    
    private var lat: Float?
    private var lon: Float?
    
    public init(lat: Float, lon: Float) {
        self.lat = lat
        self.lon = lon
    }
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
    }
    
    public static func ==(lhs: CFGeoType, rhs: CFGeoType) -> Bool {
        return lhs.lat == rhs.lat && lhs.lon == rhs.lon
    }

}

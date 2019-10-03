//
//  CFEvent.swift
//  CustomFit
//
//  Created by Rajtharan G on 22/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

struct CFEvent: Codable {
    
    private var eventProperties: [String: JSON]?
    private var eventId: JSON?
    private var eventTimeStamp: String?

    enum CodingKeys: String, CodingKey {
        case eventProperties = "data"
        case eventId = "event_customer_id"
        case eventTimeStamp = "event_timestamp"
    }
    
    init(eventID: String?, eventProperties: [String: JSON]?) {
        self.eventProperties = eventProperties
        self.eventTimeStamp = CFUtil.getSupportedDateFormat().string(from: Date())
        if let eventID = eventID {
            self.eventId = JSON(stringLiteral: eventID)
        }
    }
    
    init(builder: EventBuilder?) {
        self.eventTimeStamp = CFUtil.getSupportedDateFormat().string(from: Date())
        if let eventID = builder?.eventId {
            self.eventId = JSON(stringLiteral: eventID)
        }
        if let eventProperties = builder?.eventProperties {
            self.eventProperties = eventProperties
        }
    }
    
}

public class EventBuilder {
    
    var eventId: String?
    var eventProperties: [String: JSON]?
    
    //
    init(id: String) {
        self.eventId = id
        self.eventProperties = [:]
    }
    
    func eventProperty(k: String, v: String) -> EventBuilder {
        return eventProperty(map: eventProperties, k: k, v: JSON(stringLiteral: v))
    }
    
    func eventProperty(k: String, v: Date) -> EventBuilder {
        return eventProperty(map: eventProperties, k: k, v: JSON(stringLiteral: CFUtil.getSupportedDateFormat().string(from: v)))
    }
    
    func eventProperty(k: String, v: CFGeoType) -> EventBuilder { // FIXME:-
        return eventProperty(map: eventProperties, k: k, v: JSON(stringLiteral: CFUtil.toString(geoType: v)))
    }
    
    func eventProperty(map: [String: JSON]?, k: String?, v: JSON?) -> EventBuilder {
        if let k = k, let v = v {
            eventProperties?[k] = v
        }
        return self
    }
    
    func eventProperty(k: String, n: NSNumber) -> EventBuilder {
        return eventProperty(map: eventProperties, k: k, v: JSON(integerLiteral: n.intValue))
    }
    
    func eventProperty(k: String, b: Bool) -> EventBuilder {
        return eventProperty(map: eventProperties, k: k, v: JSON(booleanLiteral: b))
    }
    
    func eventPropertyString(k: String, vs: [String]) -> EventBuilder {
        var array: [JSON] = []
        for value in vs {
            array.append(JSON(stringLiteral: value))
        }
        return eventProperty(map: eventProperties, k: k, v: JSON(array: array))
    }
    
    func eventPropertyString(map:  [String: JSON]?, k: String, vs: [String?]) -> EventBuilder {
        var array: [JSON] = []
        for v in vs {
            if let v = v {
                array.append(JSON(stringLiteral: v))
            }
        }
        eventProperties?[k] = JSON(array: array)
        return self
    }
    
    func eventPropertyNumber(k: String, vs: [NSNumber]) -> EventBuilder {
        return eventPropertyNumber(map: eventProperties, k: k, vs: vs)
    }
    
    func eventPropertyNumber(map: [String: JSON]?, k: String, vs: [NSNumber?]) -> EventBuilder {
        var array: [JSON] = []
        for v in vs {
            if let v = v {
                array.append(JSON(integerLiteral: v.intValue))
            }
        }
        eventProperties?[k] = JSON(array: array)
        return self
    }
    
    func eventPropertyDate(k: String, vs: [Date]) -> EventBuilder {
        return eventPropertyDate(map: eventProperties, k: k, vs: vs)
    }
    
    func eventPropertyDate(map: [String: JSON]?, k: String, vs: [Date?]) -> EventBuilder {
        var array: [JSON] = []
        for v in vs {
            if let v = v {
                array.append(JSON(stringLiteral: CFUtil.getSupportedDateFormat().string(from: v)))
            }
        }
        eventProperties?[k] = JSON(array: array)
        return self
    }
    
    func eventPropertyGeoPoint(k: String, vs: [CFGeoType]) -> EventBuilder {
        return eventPropertyGeoPoint(map: eventProperties, k: k, vs: vs)
    }
    
    func eventPropertyGeoPoint(map: [String: JSON]?, k: String, vs: [CFGeoType?]) -> EventBuilder {
        var array: [JSON] = []
        for v in vs {
            if let v = v {
                array.append(JSON(stringLiteral: CFUtil.toString(geoType: v)))
            }
        }
        eventProperties?[k] = JSON(array: array)
        return self
    }
    
    func build() -> CFEvent {
        return CFEvent.init(eventID: eventId, eventProperties: eventProperties)
    }
    
}

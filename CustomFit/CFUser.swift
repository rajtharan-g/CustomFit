//
//  CFUser.swift
//  CustomFit
//
//  Created by Rajtharan G on 14/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit

let DEVICE: String = "device"
let OS: String = "os"
let IP: String = "ip"
let EMAIL: String = "email"
let PHONE_NUMBER: String = "phone_number"
let FIRST_NAME: String = "first_name"
let LAST_NAME : String = "last_name"
let COUNTRY: String = "country"
let COUNTRY_CODE: String = "country_code"
let TIME_ZONE: String = "time_zone"
let ANONYMOUS: String = "anonymous"
let GENDER: String = "gender"
let DOB: String = "dob"
let DEFAULT_LOCATION: String = "default_location"

public struct CFUser: Codable {
    
    public var id: String?
    public var anonymous: Bool?
    public var ip: String?
    public var email: String?
    public var phoneNumber: String?
    public var country: String?
    public var countryCode: String?
    public var defaultLocation: CFGeoType?
    public var gender: CFGender?
    public var dob: String?
    public var firstName: String?
    public var lastName: String?
    public var timeZone: String?
    public var tags: [String: String]?
    public var customProperties: [String: JSON]?
    var privatePropertyNames: PrivatePropertyNames?
    public var deviceId: String?
    public var cfUserId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_customer_id"
        case anonymous
        case ip
        case email
        case phoneNumber = "phone_number"
        case countryCode = "country_code"
        case defaultLocation = "default_location"
        case gender
        case dob
        case firstName = "first_name"
        case lastName = "last_name"
        case country
        case timeZone = "time_zone"
        case tags
        case customProperties = "properties"
        case privatePropertyNames = "private_fields"
        case deviceId
        case cfUserId = "user_id"
    }
    
    public init(builder: UserBuilder?) {
        if let id = builder?.id as? String, !id.isEmpty {
            self.id = id
            self.anonymous = builder?.anonymous
        } else {
            print("CustomFit.ai","User was created with null/empty ID. Using device-unique anonymous user id: " + CustomFit.getUniqueUserInstanceId())
            self.id = CustomFit.getUniqueUserInstanceId()
            self.anonymous = true
        }
        
        self.ip = builder?.ip
        self.country = builder?.country
        self.firstName = builder?.firstName
        self.lastName = builder?.lastName
        self.email = builder?.email
        self.phoneNumber = builder?.phoneNumber
        self.timeZone = builder?.timeZone as? String
        self.customProperties = builder?.customProperties
        self.privatePropertyNames = builder?.privatePropertyNames
        self.countryCode = builder?.countryCode
        self.gender = builder?.gender
        self.defaultLocation = builder?.defaultLocation
        if let builderTags = builder?.tags {
            for tag in builderTags {
                if self.tags != nil {
                    self.tags?[tag] = ""
                } else {
                    self.tags = [:]
                    self.tags?[tag] = ""
                }
            }
        }
        if let dob = builder?.dob {
            self.dob = CFUtil.getSupportedDateFormat().string(from: dob)
        }
    }
    
    mutating public func clear() {
        self.id = nil
        self.anonymous = nil
        self.ip = nil
        self.country = nil
        self.firstName = nil
        self.lastName = nil
        self.email = nil
        self.phoneNumber = nil
        self.timeZone = nil
        self.customProperties = nil
        self.privatePropertyNames = nil
        self.countryCode = nil
        self.gender = nil
        self.defaultLocation = nil
        self.tags = nil
        self.dob = nil
    }
    
}

struct PrivatePropertyNames: Codable {
    
    public var fields: [String]?
    public var properties: [String]?
    public var tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case fields = "user_fields"
        case properties = "properties"
        case tags = "tags"
    }
    
    public init() {
        fields = Array()
        properties = Array()
        tags = Array()
    }
    
}

public class UserBuilder: NSObject {
    
    var id: Any?
    var anonymous: Bool?
    var ip: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var timeZone: Any?
    var gender: CFGender?
    var phoneNumber: String?
    var dob: Date?
    var countryCode: String?
    var defaultLocation: CFGeoType?
    var country: String?
    var customProperties: [String: JSON]?
    var privatePropertyNames: PrivatePropertyNames?
    var tags: [String]?
    
    public init(id: String) {
        self.id = id
        self.customProperties = Dictionary()
        self.customProperties?[OS] = JSON(stringLiteral: UIDevice.current.systemVersion)
        self.customProperties?[DEVICE] = JSON(stringLiteral: "\(UIDevice.current.name) \(UIDevice.current.model)")
        self.privatePropertyNames = PrivatePropertyNames()
        self.tags = Array()
    }
    
    public init(user: CFUser) {
        self.id = user.id
        self.ip = user.ip
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.phoneNumber = user.phoneNumber
        self.timeZone = user.timeZone
        self.email = user.email
        self.country = user.country
        self.customProperties = user.customProperties
        self.tags = Array(user.tags?.keys ?? [:].keys)
        self.privatePropertyNames = user.privatePropertyNames
        if let dob = user.dob {
            self.dob = CFUtil.getSupportedDateFormat().date(from:dob)
        }
        self.defaultLocation = user.defaultLocation
    }
    
    public func id(s: String) -> UserBuilder {
        self.id = s
        return self
    }
    
    /**
     * Sets the flag for making user as anonymous.
     * Default value is false.
     * The anonymous user does not get created on CustomFit.ai
     */
    public func anonymous(s: Bool) -> UserBuilder {
        self.anonymous = s
        return self
    }
    
    /**
     * Sets the IP address of user.
     * @param ip Ip address of user
     * @return the builder
     */
    public func ip(ip: String) -> UserBuilder {
        self.ip = ip
        return self
    }
    
    /**
     * Sets the IP address of user.
     * But values are not stored in CustomFit.ai
     * @param ip - Ip address of user
     * @return the builder
     */
    public func privateIp(ip: String) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(IP)
        return self.ip(ip: ip)
    }
    
    /**
     * Sets the country of user.
     * @param country Country of user
     * @return the builder
     */
    public func country(country: String) -> UserBuilder {
        self.country = country
        return self
    }
    
    /**
     * Sets the country of user.
     * But values are not stored in CustomFit.ai
     * @param country Country of user.
     * @return the builder
     */
    public func privateCountry(country: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(COUNTRY)
        return self.country(country: country)
    }
    
    /**
     * Sets the default location of user.
     * @param defaultLocation Default location of user.
     *                        i.e., latitude and longitude
     * @return the builder
     */
    public func defaultLocation(defaultLocation: CFGeoType) -> UserBuilder {
        self.defaultLocation = defaultLocation
        return self
    }
    
    /**
     * Sets the default location of user.
     * But values are not stored in CustomFit.ai
     * @param defaultLocation Default location of user.
     *                        i.e., latitude and longitude
     * @return the builder
     */
    public func privateDefaultLocation(defaultLocation: CFGeoType) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(DEFAULT_LOCATION)
        return self.defaultLocation(defaultLocation: defaultLocation)
    }
    
    /**
     * Sets the timezone of user.
     * @param timeZone Timezone of user
     * @return the builder
     */
    public func timeZone(timeZone: String) -> UserBuilder {
        self.timeZone = timeZone
        return self
    }
    
    /**
     * Sets the timezone of user.
     * But values are not stored in CustomFit.ai
     * @param timeZone Timezone of user.
     * @return the builder
     */
    public func privateTimeZone(timeZone: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(TIME_ZONE)
        return self.timeZone(timeZone: timeZone)
    }
    
    /**
     * Sets the gender of user.
     * @param gender - Gender of user
     * @return the builder
     *
     */
    public func gender(gender: String?) -> UserBuilder {
        guard let gender = gender else {
            return self
        }
        if gender.elementsEqual("MALE") {
            self.gender = CFGender.male
        } else if gender.elementsEqual("FEMALE") {
            self.gender = CFGender.female
        } else {
            self.gender = CFGender.other
        }
        return self
    }
    
    /**
     * Sets the gender of user.
     * But values are not stored in CustomFit.ai
     * @param gender Gender of user
     * @return the builder
     */
    public func privateGender(gender: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(GENDER)
        return self.gender(gender: gender)
    }
    
    /**
     * Sets the phone number of user.
     * @param phoneNumber - Phone number of user
     * @return the builder
     *
     */
    public func phoneNumber(countryCode: String, phoneNumber: String) -> UserBuilder {
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
        return self
    }
    
    
    /**
     * Sets the phone number of user.
     * But values are not stored in CustomFit.ai
     * @param phoneNumber Phone number of user
     * @return the builder
     */
    public func privatePhoneNumber(countryCode: String, phoneNumber: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(PHONE_NUMBER)
        self.privatePropertyNames?.fields?.append(COUNTRY_CODE)
        return self.phoneNumber(countryCode: countryCode, phoneNumber: phoneNumber)
    }
    
    /**
     * Sets the tags of user.
     * @param s List of tags related to user
     * @return the builder
     *
     */
    public func tags(s: [String]) -> UserBuilder {
        self.tags = s
        return self
    }
    
    /**
     * Sets the tags of user.
     * But values are not stored in CustomFit.ai
     * @param s List of tags related to user
     * @return the builder
     *
     */
    public func privateTags(s: [String]) -> UserBuilder {
        self.privatePropertyNames?.tags = s
        return self
    }
    
    /**
     * Sets the first name of user.
     * @param firstName First name of user
     * @return the builder
     */
    public func firstName(firstName: String) -> UserBuilder {
        self.firstName = firstName
        return self
    }
    
    /**
     * Sets the first name of user.
     * But values are not stored in CustomFit.ai
     * @param firstName First name of user
     * @return the builder
     */
    public func privateFirstName(firstName: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(FIRST_NAME)
        return self.firstName(firstName: firstName)
    }
    
    /**
     * Sets the last name of user.
     * @param lastName Last name of user
     * @return the builder
     */
    public func lastName(lastName: String) -> UserBuilder {
        self.lastName = lastName
        return self
    }
    
    /**
     * Sets the last name of user.
     * But values are not stored in CustomFit.ai
     * @param lastName Last name of user
     * @return the builder
     */
    public func privateLastName(lastName: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(LAST_NAME)
        return self.lastName(lastName: lastName)
    }
    
    /**
     * Sets the date of birth of user.
     * @param dob Date of birth of user
     * @return the builder
     */
    public func dob(dob: Date) -> UserBuilder {
        self.dob = dob
        return self
    }
    
    /**
     * Sets the date of birth of user.
     * But values are not stored in CustomFit.ai
     * @param dob Date of birth of user
     * @return the builder
     */
    public func privateDoB(dob: Date) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(DOB)
        return self.dob(dob: dob)
    }
    
    /**
     * Sets the email of user.
     * @param email Email of user
     * @return the builder
     */
    public func email(email: String) -> UserBuilder {
        self.email = email
        return self
    }
    
    /**
     * Sets the email of user.
     * But values are not stored in CustomFit.ai
     * @param email Email of user
     * @return the builder
     */
    public func privateEmail(email: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(EMAIL)
        return self.email(email: email)
    }
    
    /**
     * If the custom string property is not there then it gets created at CustomFit.ai
     * Sets the custom string property of user.
     * @param key Key for custom string property
     * @param value Value for custom string property
     * @return the builder
     */
    public func customProperty(key: String, value: String) -> UserBuilder {
        return customProperty(k: key, v: JSON(stringLiteral: value))
    }
    
    /**
     * If the custom string property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom string property
     * @param value Value for custom string property
     * @return the builder
     */
    public func privateCustomProperty(key: String, value: String) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return self.customProperty(key: key, value: value)
    }
    
    /**
     * If the custom date property is not there then it gets created at CustomFit.ai
     * Sets the custom date property of user.
     * @param key Key for custom date property
     * @param value Value for custom date property
     * @return the builder
     */
    public func customProperty(key: String, value: Date) -> UserBuilder {
        return customProperty(k: key, v: JSON(stringLiteral: CFUtil.getSupportedDateFormat().string(from: value)))
    }
    
    /**
     * If the custom date property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom date property
     * @param value Value for custom date property
     * @return the builder
     */
    public func privateCustomProperty(key: String, value: Date) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return self.customProperty(key: key, value: value)
    }
    
    /**
     * If the custom geo point property is not there then it gets created at CustomFit.ai
     * Sets the custom geo point property of user.
     * @param key Key for custom geo point property
     * @param value Value for custom geo pointproperty
     * @return the builder
     */
    public func customProperty(key: String, value: CFGeoType) -> UserBuilder {
        return customProperty(k: key, v: JSON(dictionaryLiteral: value))
    }
    
    /**
     * If the custom geo point property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom geo point property
     * @param value Value for custom geo pointproperty
     * @return the builder
     */
    public func privateCustomProperty(key: String, value: CFGeoType) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return customProperty(key: key, value: value)
    }
    
    private func customProperty(k: String?, v: JSON?) -> UserBuilder {
        if let k = k, let v = v {
            customProperties?[k] = v
            return self
        }
        return self
    }
    
    /**
     * If the number custom property is not there then it gets created at CustomFit.ai
     * Sets the number custom property of user.
     * @param key Key for number custom property
     * @param value Value for number custom property
     * @return the builder
     */
    
    public func customProperty(key: String, value: Int64) -> UserBuilder {
        return self.customProperty(k: key, v: JSON(integerLiteral: Int(value)))
    }
    
    /**
     * If the number custom property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for number custom property
     * @param value Value for number custom property
     * @return the builder
     */
    public func privateCustomProperty(key: String, value: Int64) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return customProperty(key: key, value: value)
    }
    
    /**
     * If the custom boolean property is not there then it gets created at CustomFit.ai
     * Sets the custom boolean property of user.
     * @param key Key for custom boolean property
     * @param value Value for custom boolean property
     * @return the builder
     */
    public func customProperty(key: String, value: Bool) -> UserBuilder {
        return customProperty(k: key, v: JSON(booleanLiteral: value))
    }
    
    
    /**
     * If the custom boolean property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom boolean property
     * @param value Value for custom boolean property
     * @return the builder
     */
    public func privateCustomProperty(key: String, value: Bool) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return self.customProperty(key: key, value: value)
    }
    
    /**
     * If the custom list string property is not there then it gets created at CustomFit.ai
     * Sets the custom list string property of user.
     * @param key Key for custom list string property
     * @param values List of values for custom list string property
     * @return the builder
     */
    public func customPropertyString(key: String, values: [String]) -> UserBuilder {
        var array: [JSON] = []
        for value in values {
            array.append(JSON(stringLiteral: value))
        }
        return customProperty(k: key, v: JSON(array: array))
    }
    
    /**
     * If the custom list string property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom list string property
     * @param values List of values for custom list string property
     * @return the builder
     */
    public func privateCustomPropertyString(key: String, values: [String]) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return customPropertyString(key: key, values: values)
    }
    
    private func customProperty(key: String, values: [String?]) -> UserBuilder {
        var array = Array<JSON>()
        for value in values {
            if let v = value {
                array.append(JSON(stringLiteral: v))
            }
        }
        customProperties?[key] = JSON(array: array)
        return self
    }
    
    /**
     * If the custom list number property is not there then it gets created at CustomFit.ai
     * Sets the custom list number property of user.
     * @param key Key for custom list number property
     * @param values Value for custom list number property
     * @return the builder
     */
    public func customPropertyNumber(key: String, values: [Int64]) -> UserBuilder {
        return self.customPropertyNumber(k: key, vs: values)
    }
    
    /**
     * If the custom list number property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom list number property
     * @param values Value for custom list number property
     * @return the builder
     */
    public func privateCustomPropertyNumber(key: String, values: [Int64]) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return self.customPropertyNumber(key: key, values: values)
    }
    
    private func customPropertyNumber(k: String, vs: [Int64?]) -> UserBuilder {
        var array = Array<JSON>()
        for v in vs {
            if let v = v {
                array.append(JSON(integerLiteral: Int(v)))
            }
        }
        customProperties?[k] = JSON(array: array)
        return self
    }
    
    /**
     * If the custom list date property is not there then it gets created at CustomFit.ai
     * Sets the custom list date property of user.
     * @param key Key for custom list date property
     * @param values Value for custom list date property
     * @return the builder
     */
    public func customPropertyDate(key: String, values: [Date]) -> UserBuilder {
        return customPropertyDate(k: key, vs: values)
    }
    
    
    /**
     * If the custom list date property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom list date property
     * @param values Value for custom list date property
     * @return the builder
     */
    public func privateCustomPropertyDate(key: String, values: [Date]) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return customPropertyDate(key: key, values: values)
    }
    
    public func customPropertyDate(k: String, vs: [Date?]) -> UserBuilder {
        var array = Array<JSON>()
        for v in vs {
            if let v = v {
                let dateString = CFUtil.getSupportedDateFormat().string(from: v)
                array.append(JSON(stringLiteral: dateString))
            }
        }
        customProperties?[k] = JSON(array: array)
        return self
    }
    
    public func customPropertyGeoPoint(k: String, vs: [CFGeoType?]) -> UserBuilder {
        var array = Array<JSON>()
        for v in vs {
            if let v = v {
                array.append(JSON(dictionaryLiteral: v))
            }
        }
        customProperties?[k] = JSON(array: array)
        return self
    }
    
}

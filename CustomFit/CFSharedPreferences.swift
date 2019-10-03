//
//  swift
//  CustomFit
//
//  Created by Rajtharan G on 20/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

class CFSharedPreferences {
    
    static let shared = CFSharedPreferences()
    
    private let defaults = UserDefaults.standard
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private let PREF_CONFIG_PREFIX: String = "CF-CONFIG-KEY_"
    private let PREF_CONFIG_REQUEST_SUMMARY_PREFIX: String = "CF-CONFIG-FETCH-SUMMARY-KEY_"
    private let PREF_CONFIG_STORED_DATETIME_PREFIX: String = "CF-CONFIG-STORED-DATETIME-KEY_"
    private let PREF_CONFIG_REQUEST_SUMMARY_STORED_DATETIME_PREFIX: String = "CF-CONFIG-FETCH-SUMMARY-STORED-DATETIME-KEY_"
    private let PREF_EVENT_PREFIX: String = "CF-EVENT-KEY_"
    private let PREF_CONFIGURED_EVENTS_PREFIX: String = "CF-CONFIGURED-EVENTS-KEY"
    private let PREF_SDK_CONFIGS_PREFIX: String = "CF-SDK-CONFIGS-KEY"
    private let PREF_EVENT_STORED_DATETIME_PREFIX: String = "CF-EVENT-STORED-DATETIME-KEY_"
    private let PREF_USERINFO = "CF-USERINFO-KEY_"
    private let PREF_CLIENT_KEY = "CF-CLIENT-KEY_"
    
    private var sharedPrefConfigs: String!
    private var sharedPrefEvents: String!
    private var sharedPrefConfigRequestSummary: String!
    private var sharedPrefConfiguredEvents: String!
    private var sharedPrefConfigStoredDateTime: String!
    private var sharedPrefConfigRequestSummaryStoredDateTime: String!
    private var sharedPrefEventStoredDateTime: String!
    private var sharedPrefUserInfo: String!
    private var sharedPrefClientKey: String!
    private var sharedPrefSdkConfig: String!
    private var clientKey: String?
    private var configNextFetchDateTime: Date?
    private var configRequestSummaryFlushDate: Date?
    private var eventStoredDateTime: Date!
    private var user: CFUser?
    private var configs: Dictionary<String, CFConfig>?
    private var sdkConfigs: Dictionary<String, String>?
    private var configuredEvents: Dictionary<String, CFConfiguredEvent>?
    private let TAG: String = "CusfomFit.ai"
    private let serialQueueLabel: String = "com.customfit.ai.queue"
    //
    private init() {
        clientKey = CustomFit.shared.clientKey
        user = CustomFit.shared.user
        sharedPrefConfigs = PREF_CONFIG_PREFIX + (user?.id ?? "")
        sharedPrefConfigRequestSummary = PREF_CONFIG_REQUEST_SUMMARY_PREFIX + (user?.id ?? "")
        sharedPrefConfiguredEvents = PREF_CONFIGURED_EVENTS_PREFIX
        sharedPrefSdkConfig = PREF_SDK_CONFIGS_PREFIX
        sharedPrefEvents = PREF_EVENT_PREFIX + (user?.id ?? "")
        sharedPrefConfigStoredDateTime = PREF_CONFIG_STORED_DATETIME_PREFIX + (user?.id ?? "")
        sharedPrefConfigRequestSummaryStoredDateTime = PREF_CONFIG_REQUEST_SUMMARY_STORED_DATETIME_PREFIX + (user?.id ?? "")
        sharedPrefEventStoredDateTime = PREF_EVENT_STORED_DATETIME_PREFIX + (user?.id ?? "")
        sharedPrefUserInfo = PREF_USERINFO
        sharedPrefClientKey = PREF_CLIENT_KEY
        setClientKey(ckey: clientKey)
        setUserInfo(cfUser: user)
        configRequestSummaryFlushDate = nil
        configNextFetchDateTime = nil
        eventStoredDateTime = nil
    }
    
    func reset() {
        user = nil
        clientKey = nil
    }
    
    //
    func initFromCache() {
        sharedPrefUserInfo = PREF_USERINFO
        sharedPrefClientKey = PREF_CLIENT_KEY
        
        user = getUser()
        clientKey = getClientKey()
        
        sharedPrefConfigs = PREF_CONFIG_PREFIX + (user?.id ?? "")
        sharedPrefConfigRequestSummary = PREF_CONFIG_REQUEST_SUMMARY_PREFIX + (user?.id ?? "")
        sharedPrefConfiguredEvents = PREF_CONFIGURED_EVENTS_PREFIX
        sharedPrefSdkConfig = PREF_SDK_CONFIGS_PREFIX
        sharedPrefEvents = PREF_EVENT_PREFIX + (user?.id ?? "")
        sharedPrefConfigStoredDateTime = PREF_CONFIG_STORED_DATETIME_PREFIX + (user?.id ?? "")
        sharedPrefConfigRequestSummaryStoredDateTime = PREF_CONFIG_REQUEST_SUMMARY_STORED_DATETIME_PREFIX + (user?.id ?? "")
        sharedPrefEventStoredDateTime = PREF_EVENT_STORED_DATETIME_PREFIX + (user?.id ?? "")
    }
    
    private func getUserId() -> String? {
        if let user = user {
            return user.id
        }
        user = getUser()
        if let user = user {
            return user.id
        }
        return nil
    }
    //
    func setUserInfo(cfUser: CFUser?) {
        dispatch_queue_serial_t(label: serialQueueLabel).sync {
            if let cfUser = cfUser {
                self.user = cfUser
                do {
                    let encoded = try PropertyListEncoder().encode(cfUser)
                    defaults.set(encoded, forKey: sharedPrefUserInfo)
                } catch let error {
                    print(TAG, "Exception: \(error.localizedDescription)")
                }
            }
        }
    }
    //
    func setClientKey(ckey: String?) {
        dispatch_queue_serial_t(label: serialQueueLabel).sync {
            if let ckey = ckey {
                self.clientKey = ckey
                defaults.set(ckey, forKey: sharedPrefClientKey)
            }
        }
    }
    //
    func setConfigs(configList: Dictionary<String, CFConfig>?) {
        if let configList = configList {
            configs = configList
            do {
                let encoded = try encoder.encode(configList)
                defaults.set(encoded, forKey: sharedPrefConfigs)
                let configNextFetchDateTime = Date().addingTimeInterval(TimeInterval(CFSDKConfig.shared.getConfigRefershDuration()))
                defaults.set(configNextFetchDateTime, forKey: sharedPrefConfigStoredDateTime)
            } catch let error {
                print(TAG, "Exception: \(error.localizedDescription)")
            }
        }
    }
    
    func setSdkConfigs(configList: Dictionary<String, String>?) {
        if let configList = configList {
            sdkConfigs = configList
            defaults.set(configList, forKey: sharedPrefSdkConfig)
        }
    }
    
    func setConfiguredEvents(events: Dictionary<String, CFConfiguredEvent>?) {
        if let events = events {
            configuredEvents = events
            do {
                let encoded = try encoder.encode(events)
                defaults.set(encoded, forKey: sharedPrefConfiguredEvents)
            } catch let error {
                print(TAG, "Exception: \(error.localizedDescription)")
            }
        }
    }
    //
    func setConfigNextFetchDateTime(date: Date?) {
        if let date = date {
            configNextFetchDateTime = date
            defaults.set(date, forKey: sharedPrefConfigStoredDateTime)
        }
    }
    //
    func setEvents(events: CFQueue<CFEvent>?) {
        if let events = events {
            do {
                let encoded = try encoder.encode(events.elements)
                defaults.set(encoded, forKey: sharedPrefEvents)
            } catch let error {
                print(TAG, "Exception: \(error.localizedDescription)")
            }
        }
    }
    
    func setEventsFlushDate(date: Date?) {
        if let date = date {
            eventStoredDateTime = date
            defaults.set(date, forKey: sharedPrefEventStoredDateTime)
        }
    }
    
    func setConfigRequestSummary(events: Array<CFConfigRequestSummary>?) {
        if let events = events {
            do {
                let encoded = try encoder.encode(events)
                defaults.set(encoded, forKey: sharedPrefConfigRequestSummary)
            } catch let error {
                print(TAG, "Exception: \(error.localizedDescription)")
            }
        }
    }
    
    func setConfigRequestSummaryFlushDate(date: Date?) {
        if let date = date {
            configRequestSummaryFlushDate = date
            defaults.set(date, forKey: sharedPrefConfigRequestSummaryStoredDateTime)
        }
    }
    //
    func getUser() -> CFUser? {

        if let user = user {
            return user
        }
        if let user = defaults.object(forKey: sharedPrefUserInfo) as? Data {
            do {
                let loadedUser = try PropertyListDecoder().decode(CFUser.self, from: user)
                return loadedUser
            } catch let error {
                print(TAG, "Exception: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    func getClientKey() -> String? {
        if let clientKey = clientKey {
            return clientKey
        }
        if let clientKey = defaults.object(forKey: sharedPrefClientKey) as? String {
           return clientKey
        }
        return nil
    }
    
    func getLastEventStoredDateTime() -> Date? {

        if let eventStoredDateTime = eventStoredDateTime {
            return eventStoredDateTime
        }
        if let eventStoredDateTime = defaults.object(forKey: sharedPrefEventStoredDateTime) as? Data {
            do {
                let loadedEventStoredDateTime = try decoder.decode(Date.self, from: eventStoredDateTime)
                return loadedEventStoredDateTime
            } catch let error {
                print(TAG, "Exception: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    func getConfigNextFetchDateTime() -> Date? {

        if let configNextFetchDateTime = configNextFetchDateTime {
            return configNextFetchDateTime
        }
        return defaults.object(forKey: sharedPrefConfigStoredDateTime) as? Date
    }
    
    func getLastConfigRequestSummaryStoredDateTime() -> Date? {

        if let configRequestSummaryFlushDate = configRequestSummaryFlushDate {
            return configRequestSummaryFlushDate
        }
        if let lastConfigRequestSummaryStoredDateTime = defaults.object(forKey: sharedPrefConfigRequestSummaryStoredDateTime) as? Data {
            do {
                let loadedLastConfigRequestSummaryStoredDateTime = try decoder.decode(Date.self, from: lastConfigRequestSummaryStoredDateTime)
                return loadedLastConfigRequestSummaryStoredDateTime
            } catch let error {
                print(TAG, "Exception: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    func getConfigs() -> Dictionary<String, CFConfig>? {

        if let configs = configs {
            return configs
        }
        if let config = defaults.object(forKey: sharedPrefConfigs) as? Data {
            return try? decoder.decode(Dictionary<String, CFConfig>.self, from: config)
        }
        return nil
    }
    //
    func getSdkConfigs() -> Dictionary<String, String>? {

        if let sdkConfigs = sdkConfigs {
            return sdkConfigs
        }
        return defaults.object(forKey: sharedPrefSdkConfig) as? Dictionary<String, String>
    }
    
    func getConfiguredEvents() -> Dictionary<String, CFConfiguredEvent>? {
        if let configuredEvents = configuredEvents {
            return configuredEvents
        }
        if let event = defaults.object(forKey: sharedPrefConfiguredEvents) as? Data {
            do {
                let loadedEvent = try decoder.decode(Dictionary<String, CFConfiguredEvent>.self, from: event)
                return loadedEvent
            } catch let error {
                print(TAG, "Exception: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    func getConfigRequestSummaryEvents() -> CFQueue<CFConfigRequestSummary>? {
        if let events = defaults.object(forKey: sharedPrefConfigRequestSummary) as? Data {
            do {
                let loadedEvents = try decoder.decode(Array<CFConfigRequestSummary>.self, from: events)
                return CFQueue(elements: loadedEvents)
            } catch let error {
                print(TAG, "Exception: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    func getEvent() -> CFQueue<CFEvent>? {
        if let events = defaults.object(forKey: sharedPrefEvents) as? Data {
            do {
                let loadedEvents = try decoder.decode(Array<CFEvent>.self, from: events)
                return CFQueue(elements: loadedEvents)
            } catch let error {
                print(TAG, "Exception: \(error.localizedDescription)")
            }
        }
        return nil
    }

}

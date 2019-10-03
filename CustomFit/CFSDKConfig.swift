//
//  self.swift
//  CustomFit
//
//  Created by Rajtharan G on 23/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

class CFSDKConfig {
    
    static let shared = CFSDKConfig()
    
    var CONFIG_REFRESH_DURATION_KEY: String = "cf_android_sdk_config_refresh_duration"
    var CONFIG_REFRESH_DURATION_ADDITIONAL_RANDOM_ADD_KEY: String = "cf_android_sdk_config_refresh_duration_additional_random_add"
    var API_RETRY_COUNT_KEY: String = "cf_android_sdk_api_retry_count"
    var PERIODIC_EVENT_PROCESSOR_INTERVAL_KEY: String = "cf_android_sdk_config_periodic_event_processor_interval"
    var EVENT_QUEUE_POLL_DURATION_KEY: String = "cf_android_sdk_config_event_queue_poll_duration"
    var EVENT_QUEUE_SIZE_KEY: String = "cf_android_sdk_config_event_queue_size"
    var CONFIG_REQUEST_SUMMARY_QUEUE_POLL_DURATION_KEY: String = "cf_android_sdk_config_config_fetch_summary_queue_poll_duration"
    var CONFIG_REQUEST_SUMMARY_QUEUE_SIZE_KEY: String = "cf_android_sdk_config_config_fetch_summary_queue_size"
    var API_EXPONENTIAL_BACKOFF_DELAY_KEY: String = "cf_android_sdk_exponential_backoff_time"
    
    var CONFIG_REFRESH_DURATION_ADDITIONAL_RANDOM_ADD_VALUE: Int = 300000
    var CONFIG_REFRESH_DURATION_VALUE: Int = 0
    var API_RETRY_COUNT_VALUE: Int = 10
    var PERIODIC_EVENT_PROCESSOR_INTERVAL_VALUE: Int = 900000
    var EVENT_QUEUE_POLL_DURATION_VALUE: Int = 900000
    var EVENT_QUEUE_SIZE_VALUE: Int = 0
    var CONFIG_REQUEST_SUMMARY_QUEUE_POLL_DURATION_VALUE: Int = 900000
    var CONFIG_REQUEST_SUMMARY_QUEUE_SIZE_VALUE: Int = 0
    var API_EXPONENTIAL_BACKOFF_DELAY_VALUE: Int = 15000
    
    var sdkConfigs: [String : String]?
    var SDK_CONFIG_FETCHER_WORKER_NAME: String = "SDK_CONFIG_FETCHER_WORKER_NAME"
    var sdkConfigFetchWorkRequest: DispatchWorkItem?
    var CONFIGURED_EVENT_FETCHER_WORKER_NAME: String = "CONFIGURED_EVENTS_FETCHER"
    var configuredEventFetchWorkRequest: DispatchWorkItem?
    var SDK_CONFIG_FETCHER_WORKER_MAX_RETRIES: Int = 0
    var CONFIGURED_EVENT_FETCHER_WORKER_MAX_RETRIES: Int = 0
    //
    private init() {
        CONFIG_REFRESH_DURATION_VALUE = Int(43200000 + arc4random_uniform(UInt32(CONFIG_REFRESH_DURATION_ADDITIONAL_RANDOM_ADD_VALUE)))
        self.sdkConfigs = CFSharedPreferences.shared.getSdkConfigs()
        fetchSdkConfigs()
        fetchConfiguredEvents()
    }
    //
    func reset() {
        cancelConfiguredEventFetchWorkRequest()
        cancelSdkConfigFetchRequest()
    }
    
    func fetchSdkConfigs() {
        self.SDK_CONFIG_FETCHER_WORKER_MAX_RETRIES = self.getApiRetryCount()
        APIClient.shared.getSdkConfigs { (configs, error) in
            if let config = configs {
                CFSharedPreferences.shared.setSdkConfigs(configList: config)
            } 
        }
    }
    //
    func fetchConfiguredEvents() {
        self.CONFIGURED_EVENT_FETCHER_WORKER_MAX_RETRIES = self.getApiRetryCount()
        APIClient.shared.getConfiguredEvents { (configuredEvents, error) in
            if let configEvents = configuredEvents {
                CFSharedPreferences.shared.setConfiguredEvents(events: configEvents)
            } 
        }
    }
    
    func cancelSdkConfigFetchRequest() {
        if let workRequest = sdkConfigFetchWorkRequest {
            workRequest.cancel()
        }
    }
    
    func cancelConfiguredEventFetchWorkRequest() {
        if let workRequest = configuredEventFetchWorkRequest {
            workRequest.cancel()
        }
    }
    
    func getConfigRefershDurationRandomAdd() -> Int {
        return getInteger(CONFIG_REFRESH_DURATION_ADDITIONAL_RANDOM_ADD_KEY, CONFIG_REFRESH_DURATION_ADDITIONAL_RANDOM_ADD_VALUE)
    }
    //
    func getConfigRefershDuration() -> Int {
        let refreshDuration = getInteger(CONFIG_REFRESH_DURATION_KEY, CONFIG_REFRESH_DURATION_VALUE)
        if (refreshDuration != CONFIG_REFRESH_DURATION_VALUE) {
            let rand = getConfigRefershDurationRandomAdd()
            return refreshDuration + Int(arc4random_uniform(UInt32(rand)))
        }
        return refreshDuration
    }
    //
    func getApiRetryCount() -> Int {
        return getInteger(API_RETRY_COUNT_KEY, API_RETRY_COUNT_VALUE)
    }
    
    func getPeriodicEventProcessorInterval() -> Int {
        return getInteger(PERIODIC_EVENT_PROCESSOR_INTERVAL_KEY, PERIODIC_EVENT_PROCESSOR_INTERVAL_VALUE)
    }
    
    func getEventQueuePollDuration() -> Int {
        return getInteger(EVENT_QUEUE_POLL_DURATION_KEY, EVENT_QUEUE_POLL_DURATION_VALUE)
    }
    
    func getEventQueueSize() -> Int {
        return getInteger(EVENT_QUEUE_SIZE_KEY, EVENT_QUEUE_SIZE_VALUE)
    }
    
    func getConfigRequestSummaryQueuePollDuration() -> Int {
        return getInteger(CONFIG_REQUEST_SUMMARY_QUEUE_POLL_DURATION_KEY, CONFIG_REQUEST_SUMMARY_QUEUE_POLL_DURATION_VALUE)
    }
    
    func getConfigRequestSummaryQueueSize() -> Int {
        return getInteger(CONFIG_REQUEST_SUMMARY_QUEUE_SIZE_KEY,CONFIG_REQUEST_SUMMARY_QUEUE_SIZE_VALUE)
    }
    
    func getApiExponentialBackoffDelay() -> Int {
        return getInteger(API_EXPONENTIAL_BACKOFF_DELAY_KEY,API_EXPONENTIAL_BACKOFF_DELAY_VALUE)
    }
    
    func getString(key: String, fallbackValue: String) -> String {
        if let value = sdkConfigs?[key] {
            return value
        }
        return fallbackValue
    }
    
    func getInteger(_ key: String, _ fallbackValue: Int) -> Int {
        if let value = sdkConfigs?[key], let intValue = Int(value) {
            return intValue
        }
        return fallbackValue
    }
    
}

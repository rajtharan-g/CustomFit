//
//  CFTracker.swift
//  CustomFit
//
//  Created by Bharath R on 28/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

private enum EventDispatchState {
    case idle, inProgress
}

class CFTracker {
    
    static let shared = CFTracker()
    
    private var events: CFQueue<CFEvent>?
    private var lastPushTime: Date?
    private var EVENT_DISPATCHER_WORKER_NAME: String = "CUSTOMFIT_EVENT_DISPATCHER"
    private var eventDispatchWorkRequest: DispatchWorkItem? = nil
    private static var eventDispatchState: EventDispatchState = .idle
    public static var EVENT_DISPATCH_WORKER_MAX_RETRIES: Int = 0
    
    //
    init() {
        events = CFSharedPreferences.shared.getEvent()
        if events == nil {
            events = CFQueue<CFEvent>(elements: [])
        }
        
        lastPushTime = CFSharedPreferences.shared.getLastEventStoredDateTime()
        if lastPushTime == nil {
            lastPushTime = Date()
        }
        
        CFTracker.eventDispatchState = .idle
        cancelEventDispatchWorkRequest()
        flushEvents()
    }
    
    //
    func reset() {
        forceFlush()
        cancelEventDispatchWorkRequest()
        eventDispatchWorkRequest = nil
        CFTracker.eventDispatchState = .idle
    }
    
    /**
     *The trackEvent method allows you to track events that occur on your app
     * @param event event_id of the event.
     *              The event_id is used to uniquely identify the event
     *
     */
    func trackEvent(event: CFEvent?) {
        if events == nil {
            return
        }
        if let event = event {
            events?.enqueue(event)
            CFSharedPreferences.shared.setEvents(events: events)
            flushEvents()
        }
    }
    
    private func _flushEvents() {
        if events != nil && events?.size ?? 0 > 0 {
            if CFTracker.eventDispatchState != .inProgress {
                cancelEventDispatchWorkRequest()
                CFTracker.EVENT_DISPATCH_WORKER_MAX_RETRIES = CFSDKConfig.shared.getApiRetryCount()
                CFTracker.eventDispatchState = .inProgress
                eventDispatchWorkRequest = DispatchWorkItem {
                    if (self.events == nil) {
                        self.events = CFSharedPreferences.shared.getEvent()
                    }
                    let dispatchEventNumbers: Int = self.events?.size ?? 0
                    if (dispatchEventNumbers <= 0) {
                        return
                    }
                    var eventsToDispatch = Array<CFEvent>()
                    eventsToDispatch = self.events?.elements ?? []
                    self.events = CFQueue<CFEvent>(elements: [])
                    APIClient.shared.trackEvents(registerEvents: CFRegisterEvents(user: CFSharedPreferences.shared.getUser(), events: eventsToDispatch)) { (error) in
                        if error != nil {
                            for event in eventsToDispatch {
                                self.events?.enqueue(event)
                            }
                            CFTracker.eventDispatchState = .idle
                            self.lastPushTime = Date()
                            CFSharedPreferences.shared.setEvents(events: self.events)
                            CFSharedPreferences.shared.setEventsFlushDate(date: self.lastPushTime)
                        } else {
                            CFSharedPreferences.shared.setEvents(events: self.events)
                            CFTracker.eventDispatchState = .idle
                        }
                    }
                }
                eventDispatchWorkRequest?.perform()
            }
        }
    }
    
    func cancelEventDispatchWorkRequest() {
        if let eventDispatchWorkRequest = eventDispatchWorkRequest {
            eventDispatchWorkRequest.cancel()
        }
        CFTracker.eventDispatchState = .idle
    }
    
    func flushEvents() {
        let currentDate = Date()
        if (events != nil && events?.size ?? 0 >= CFSDKConfig.shared.getEventQueueSize()) || (Int(((currentDate.timeIntervalSinceNow) - (lastPushTime?.timeIntervalSinceNow ?? 0))) >= CFSDKConfig.shared.getEventQueuePollDuration()) {
            _flushEvents()
        }
    }
    
    func forceFlush() {
        if(events != nil && events?.size ?? 0 > 0) {
            _flushEvents()
        }
    }
    
    func handleAppForeground() {
        flushEvents()
    }
    
    func handleAppBackground() {
        _flushEvents()
    }
    
    func isUsedInExperience(eventId: String, vendor: String) -> Bool {
        if let configuredEventMap = CFSharedPreferences.shared.getConfiguredEvents(), let configuredEvent = configuredEventMap[eventId] {
            if configuredEvent.experiences != nil && configuredEvent.experiences?.count ?? 0 > 0 && configuredEvent.vendors != nil {
                for cVedor in configuredEventMap["eventId"]?.vendors ?? [] {
                    if vendor == cVedor {
                        return true
                    }
                }
            }
        }
        return false
    }
    
}

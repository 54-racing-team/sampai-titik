//
//  WatchSessionManager.swift
//  SampaiTitik
//
//  Created by Salman on 29/08/26.
//

import WatchConnectivity

@Observable
class WatchManager: NSObject, WCSessionDelegate {
    var isOnJourney = false
    
    var recentJouneys: [recentJourney] = []
    var currentTracking: journeyTracking?
    var selectedJourney: recentJourney?
    var isAlarmOn: Bool = true

    static let shared = WatchManager()
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        WCSession.default.receivedApplicationContext
    }
}

extension WatchManager {
    func sendStartJourney(_ journey: startJourney) {
        guard WCSession.default.isReachable == true else { return }
        do {
            let data = try JSONEncoder().encode(journey)
            WCSession.default.sendMessage(["action": "startJourney", "data": data], replyHandler: nil, errorHandler: nil)
        } catch {
            print("fail upload journey tracking data to iphone")
        }
    }
    
    func sendFinishJourney() {
        guard WCSession.default.isReachable == true else {
            print("fail upload finish journey data to iphone")
            return
        }
        
        WCSession.default.sendMessage(["action": "finishJourney"], replyHandler: nil, errorHandler: nil)
        self.isOnJourney = false
        self.currentTracking = nil
    }
    
    func sendCancelJourney() {
        guard WCSession.default.isReachable == true else {
            print("fail upload cancel journey data to iphone")
            return
        }
        
        WCSession.default.sendMessage(["action":"cancelJourney"], replyHandler: nil, errorHandler: nil)
        self.isOnJourney = false
        self.currentTracking = nil
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            guard let action = message["action"] as? String else { return }
            
            switch action {
            case "updateTracking":
                guard let tracking = message["data"] as? Data else { return }
                do {
                    let data = try JSONDecoder().decode(journeyTracking.self, from: tracking)
                    self.currentTracking = data
                    self.isOnJourney = true
                } catch {
                    print("failed to decode recentTracking from tracking: \(error)")
                }
                
            default:
                print("There is no action")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
            DispatchQueue.main.async {
                guard let action = applicationContext["action"] as? String else { return }
                
                if action == "updateRecentJourney",
                   let data = applicationContext["data"] as? Data,
                   let journeys = try? JSONDecoder().decode([recentJourney].self, from: data) {
                    self.recentJouneys = journeys
                }
            }
        }

}


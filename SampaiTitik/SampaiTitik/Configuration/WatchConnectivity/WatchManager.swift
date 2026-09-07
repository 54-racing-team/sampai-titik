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
    var activeJourney: startJourney?

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
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
}

extension WatchManager {
    func sendRecentJourney(_ journey: [recentJourney]) {
        guard WCSession.default.activationState == .activated else { return }
        do {
            let data = try JSONEncoder().encode(journey)
            try WCSession.default.updateApplicationContext(["action": "updateRecentJourney", "data": data])
        } catch {
            print("error update recent journey to watch")
        }
    }
    
    func sendJourneyTracking(_ tracking: journeyTracking) {
        guard WCSession.default.isReachable == true else { return }
        do {
            let data = try JSONEncoder().encode(tracking)
            WCSession.default.sendMessage(["action": "updateTracking", "data": data], replyHandler: nil, errorHandler: nil)
        } catch {
            print("fail upload journey tracking data to watch")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]){
        DispatchQueue.main.async {
            guard let action = message["action"] as? String else { return }
            
            switch action {
            case "startJourney":
                guard let journeyInfo = message["data"] as? Data else {
                    print("fail to load journeyInfo data from watch")
                    return
                }
                
                do {
                    let data = try JSONDecoder().decode(startJourney.self, from: journeyInfo)
                    self.activeJourney = data
                    self.isOnJourney = true
                    print("iphone get startJourney from watch")
                } catch {
                    print("failed to decode startJourney from journeyInfo: \(error)")
                }
                
            case "finishJourney":
                self.activeJourney = nil
                self.isOnJourney = false
                
            case "cancelJourney":
                self.activeJourney = nil
                self.isOnJourney = false
                
            default:
                print("action can't be handled")
            }
        }
    }

}

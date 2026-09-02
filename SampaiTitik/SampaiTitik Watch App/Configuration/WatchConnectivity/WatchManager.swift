//
//  WatchSessionManager.swift
//  SampaiTitik
//
//  Created by Salman on 29/08/26.
//

import WatchConnectivity

@Observable
class WatchManager: NSObject, WCSessionDelegate {
    var isOnJouney = false

    static let shared = WatchManager()
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]){
        DispatchQueue.main.async {
            
        }
    }
    
    
    func sendMessage(action: String,journey: startJourney){
        if WCSession.default.isReachable {
            if isOnJouney {
//                let data = try JSONEncoder().encode(journey) else
//                WCSession.default.sendMessage(["action": action, "data": data], replyHandler: nil, errorHandler: nil)
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
}


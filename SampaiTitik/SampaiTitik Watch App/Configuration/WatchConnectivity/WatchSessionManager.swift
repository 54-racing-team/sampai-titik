//
//  WatchSessionManager.swift
//  SampaiTitik
//
//  Created by Salman on 29/08/26.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]){
        
    }
    
    func sendMessage(_ message: [String: Any]){
        if WCSession.default.isReachable {

        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
}

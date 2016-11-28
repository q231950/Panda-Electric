//
//  PandaSessionAPI.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 27/11/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import RxSwift
import RxCocoa
import os.log

public class PandaSessionAPI {
    
    static let log = OSLog(subsystem: "com.elbedev.Panda", category: "PandaSessionAPI")
    let channel: RxChannel
    let userId: String
    let subject = PublishSubject<PandaSessionModel>()
    
    
    public init(channel: RxChannel, userId: String) {
        self.channel = channel
        self.userId = userId
        
        let _ = channel.rx_channelEvent().subscribe { (event: Event<ChannelEvent>) in
            guard let type = event.element else {
                os_log("received sessions error", log: PandaSessionAPI.log, type: .error)
                return
            }
            switch type {
                case .joined: self.getSessions()
                default: break
            }
        }
    }
    
    func getSessions() {
        let _ = channel.send(topic: "read:sessions", payload: ["user": userId as AnyObject]).filter({ (event: ChannelEvent) -> Bool in
            switch event {
            case .event(_): return true
            default: return false
            }
        }).subscribe(onNext: { (event: ChannelEvent) in
            os_log("received sessions response", log: PandaSessionAPI.log, type: .info)
            switch event {
            case .event(_, let sessions): self.handleSessions(json: sessions)
            default: break
            }
        }, onError: { (error: Error) in
            os_log("error receiving sessions response", log: PandaSessionAPI.log, type: .error)
        }, onCompleted: {
            os_log("receive sessions response completed", log: PandaSessionAPI.log, type: .info)
        }, onDisposed: {
            os_log("receive sessions response disposed", log: PandaSessionAPI.log, type: .info)
        })
    }
    
    public func sessions() -> Observable<PandaSessionModel> {
        return subject
    }
    
    func handleSessions(json: [String:AnyObject]) {
        guard let response = json["response"] as? [String:AnyObject],
            let sessionsJson = response["sessions"] as? [[String:AnyObject]] else {
                os_log("bad json structure ✋", log: PandaSessionAPI.log, type: .error)
                return
        }
        
        let sessions = sessionsJson.flatMap( { (sessionJson:[String:AnyObject]) -> PandaSessionModel? in
            return PandaSessionModel(dict: sessionJson)
        } )
        
        os_log("successfully parsed %i session models", log: PandaSessionAPI.log, type: .info, sessions.count)
        sessions.forEach { (session:PandaSessionModel) in
            subject.on(.next(session))
        }
    }
}

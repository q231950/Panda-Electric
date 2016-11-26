//
//  PandaSessionObservable.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 26/11/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import RxSwift
import os.log

public enum PandaSessionObservableEvent {
    case loaded(sessions: [PandaSessionModel])
}

public class PandaSessionObservable {
    
    static let log = OSLog(subsystem: "com.elbedev.Panda", category: "ViewModel")
    
    private let subject = PublishSubject<[PandaSessionModel]>()
    
    public private(set) lazy var sessions: Observable<[PandaSessionModel]> = {
        return self.subject
    }()
    
    
    public init(channel: RxChannel, userId:String) {
        let _ = channel.send(topic: "read:sessions", payload: ["user": userId as AnyObject]).filter({ (event: ChannelEvent) -> Bool in
            switch event {
            case .event(_): return true
            default: return false
            }
        }).subscribe(onNext: { (event: ChannelEvent) in
            os_log("received sessions response", log: PandaSessionObservable.log, type: .info)
            switch event {
            case .event(_, let sessions): self.handleSessions(json: sessions)
            default: break
            }
        }, onError: { (error: Error) in
            os_log("error receiving sessions response", log: PandaSessionObservable.log, type: .error)
            self.subject.on(.error(error))
        }, onCompleted: {
            os_log("receive sessions response completed", log: PandaSessionObservable.log, type: .info)
        }, onDisposed: {
            os_log("receive sessions response disposed", log: PandaSessionObservable.log, type: .info)
        })
    }
    
    func handleSessions(json: [String:AnyObject]) {
        guard let response = json["response"] as? [String:AnyObject],
              let sessionsJson = response["sessions"] as? [[String:AnyObject]] else {
            os_log("bad json structure ✋", log: PandaSessionObservable.log, type: .error)
            return
        }
        
        let sessions = sessionsJson.flatMap( { (sessionJson:[String:AnyObject]) -> PandaSessionModel? in
            return PandaSessionModel(dict: sessionJson)
        } )
        
        os_log("successfully parsed %i session models", log: PandaSessionObservable.log, type: .info, sessions.count)
        subject.on(.next(sessions))
    }
}

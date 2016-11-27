//
//  PandaSessionObservable.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 26/11/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import RxSwift
import RxCocoa
import os.log

enum TableViewEditingCommand {
    case setSessions(sessions: [PandaSessionModel])
    case deleteSession(indexPath: IndexPath)
    case moveSession(from: IndexPath, to: IndexPath)
}

public class PandaSessionViewModel {
    
    static let log = OSLog(subsystem: "com.elbedev.Panda", category: "ViewModel")
    
    let channel: RxChannel
    let userId: String
    let sessions: [PandaSessionModel]
    
    public init(channel: RxChannel, userId: String, sessions: [PandaSessionModel]) {
        self.channel = channel
        self.userId = userId
        self.sessions = sessions
        
        let _ = channel.send(topic: "read:sessions", payload: ["user": userId as AnyObject]).filter({ (event: ChannelEvent) -> Bool in
            switch event {
            case .event(_): return true
            default: return false
            }
        }).subscribe(onNext: { (event: ChannelEvent) in
            os_log("received sessions response", log: PandaSessionViewModel.log, type: .info)
            switch event {
            case .event(_, let sessions): self.handleSessions(json: sessions)
            default: break
            }
        }, onError: { (error: Error) in
            os_log("error receiving sessions response", log: PandaSessionViewModel.log, type: .error)
        }, onCompleted: {
            os_log("receive sessions response completed", log: PandaSessionViewModel.log, type: .info)
        }, onDisposed: {
            os_log("receive sessions response disposed", log: PandaSessionViewModel.log, type: .info)
        })
    }
    
    func executeCommand(_ command: TableViewEditingCommand) -> PandaSessionViewModel {
        switch command {
        case let .setSessions(newSessions):
            return PandaSessionViewModel(channel: channel, userId: userId, sessions: newSessions)
        case let .deleteSession(indexPath):
            var all = [sessions]
            all[indexPath.section].remove(at: indexPath.row)
            return PandaSessionViewModel(channel: channel, userId: userId, sessions: all[0])
        case let .moveSession(from, to):
            var all = [sessions]
            let user = all[from.section][from.row]
            all[from.section].remove(at: from.row)
            all[to.section].insert(user, at: to.row)
            
            return PandaSessionViewModel(channel: channel, userId: userId, sessions: all[0])
        }
    }
    
    func handleSessions(json: [String:AnyObject]) {
        guard let response = json["response"] as? [String:AnyObject],
              let sessionsJson = response["sessions"] as? [[String:AnyObject]] else {
            os_log("bad json structure ✋", log: PandaSessionViewModel.log, type: .error)
            return
        }
        
        let sessions = sessionsJson.flatMap( { (sessionJson:[String:AnyObject]) -> PandaSessionModel? in
            return PandaSessionModel(dict: sessionJson)
        } )
        
        os_log("successfully parsed %i session models", log: PandaSessionViewModel.log, type: .info, sessions.count)
    }
}

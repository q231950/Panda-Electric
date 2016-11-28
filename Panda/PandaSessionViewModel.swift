//
//  PandaSessionViewModel.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 26/11/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import RxSwift
import RxCocoa
import os.log

public enum TableViewEditingCommand {
    case setSessions(sessions: [PandaSessionModel])
    case addSession(session: PandaSessionModel)
    case deleteSession(indexPath: IndexPath)
    case moveSession(from: IndexPath, to: IndexPath)
}

public struct PandaSessionViewModel {
    
    static let log = OSLog(subsystem: "com.elbedev.Panda", category: "ViewModel")
    
    public let sessions: [PandaSessionModel]
    
    public init(sessions: [PandaSessionModel]) {
        self.sessions = sessions
    }
    
    public func executeCommand(_ command: TableViewEditingCommand) -> PandaSessionViewModel {
        switch command {
        case let .setSessions(newSessions):
            os_log("set %i sessions", log: PandaSessionViewModel.log, type: .error, newSessions.count)
            return PandaSessionViewModel(sessions: newSessions)
        case let .addSession(newSession):
            os_log("add session", log: PandaSessionViewModel.log, type: .error)
            var all = [sessions]
            all[0].insert(newSession, at: 0)
            return PandaSessionViewModel(sessions: all[0])
        case let .deleteSession(indexPath):
            os_log("delete session %@", log: PandaSessionViewModel.log, type: .error, indexPath.description)
            var all = [sessions]
            all[indexPath.section].remove(at: indexPath.row)
            return PandaSessionViewModel(sessions: all[0])
        case let .moveSession(from, to):
            os_log("move session from %@ to %@", log: PandaSessionViewModel.log, type: .error, from.description, to.description)
            var all = [sessions]
            let session = all[from.section][from.row]
            all[from.section].remove(at: from.row)
            all[to.section].insert(session, at: to.row)
            return PandaSessionViewModel(sessions: all[0])
        }
    }
}

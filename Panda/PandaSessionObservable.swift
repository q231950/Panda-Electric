//
//  PandaSessionObservable.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 26/11/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import RxSwift

public enum PandaSessionObservableEvent {
    case loaded(sessions: [PandaSessionModel])
}

public class PandaSessionObservable {
    private let subject = PublishSubject<[PandaSessionModel]>()
    
    public init() {
        
    }
    
    public func fire() {
        let s = [PandaSessionModel(title: "panda session model", identifier: "123456", estimates: []),
                 PandaSessionModel(title: "2nd panda session model", identifier: "234567", estimates: [])]
        subject.on(.next(s))
    }
    
    public private(set) lazy var sessions: Observable<[PandaSessionModel]> = {
        return self.subject
    }()
}

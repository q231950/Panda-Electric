import Foundation
import RxSwift

public enum SocketConnectivityState {
    case Connected
    case Disconnected(NSError?)
}

public enum RXChannelEvent {
    case Message(String)
    case Data(NSData)
}

public class RxChannel {
    private let subject = PublishSubject<RXChannelEvent>()
    let channel: Channel
    init(_ channel: Channel) {
        self.channel = channel
    }
}

public final class RxSocket : Socket {
    
    private let subject = PublishSubject<SocketConnectivityState>()
    override public var onConnect: (() -> ())? {
        set {
            super.onConnect = {
                self.subject.on(.next(.Connected))
                newValue?()
            }
        }
        get {
            return super.onConnect
        }
    }
    
    override open var onDisconnect: ((NSError?) -> ())? {
        set {
            super.onDisconnect = { (error: NSError?) -> () in
                self.subject.on(.next(.Disconnected(error)))
                newValue?(error)
            }
        }
        get {
            return super.onDisconnect
        }
    }
    
    public override init(url: URL, params: [String: String]? = nil, selfSignedSSL: Bool = false) {
        super.init(url: url, params: params, selfSignedSSL: selfSignedSSL)
        
        super.onConnect = {
            self.subject.on(.next(.Connected))
        }
        super.onDisconnect = { (error: NSError?) -> () in
            self.subject.on(.next(.Disconnected(error)))
        }
    }
    
    public func rx_channel(_ topic: String, payload: Socket.Payload) -> RxChannel {
        return RxChannel(channel(topic, payload: payload))
    }
    
    public private(set) lazy var rx_connectivity: Observable<SocketConnectivityState> = {
        return self.subject
    }()
}

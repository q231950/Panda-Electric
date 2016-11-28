import Foundation
import RxSwift

public enum SocketConnectivityState {
    case Connected
    case Disconnected(NSError?)
}

public class RxSocket {
    
    private let socket: Socket
    private let subject = PublishSubject<SocketConnectivityState>()
    
    public init(url: URL, params: [String: String]? = nil, selfSignedSSL: Bool = false) {
        socket = Socket(url: url, params: params, selfSignedSSL: selfSignedSSL)
        socket.enableLogging = false
        
        socket.onConnect = {
            self.subject.on(.next(.Connected))
        }
        socket.onDisconnect = { (error: NSError?) -> () in
            self.subject.on(.next(.Disconnected(error)))
        }
    }
    
    public func connect() -> Observable<SocketConnectivityState>{
        socket.connect()
        return subject
    }
    
    public func channel(_ topic: String, payload: Socket.Payload) -> RxChannel {
        return RxChannel(socket, 👨‍🚀:subject, topic: topic, payload: payload)
    }
    
    public private(set) lazy var rx_connectivity: Observable<SocketConnectivityState> = {
        return self.subject
    }()
}

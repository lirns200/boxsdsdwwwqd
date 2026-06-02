import Foundation

final class GameSocketClient {
    enum State {
        case idle
        case connecting
        case connected
        case closed
        case failed(Error)
    }

    var onState: ((State) -> Void)?
    var onEnvelope: ((SocketEnvelope) -> Void)?

    private let session: URLSession
    private var task: URLSessionWebSocketTask?
    private let queue = DispatchQueue(label: "socket-client-queue")

    init(session: URLSession = .shared) {
        self.session = session
    }

    func connect(url: URL) {
        queue.async {
            self.task?.cancel(with: .normalClosure, reason: nil)
            self.task = nil

            self.onState?(.connecting)
            let task = self.session.webSocketTask(with: url)
            self.task = task
            task.resume()
            self.onState?(.connected)
            self.receiveLoop()
        }
    }

    func close() {
        queue.async {
            self.task?.cancel(with: .normalClosure, reason: nil)
            self.task = nil
            self.onState?(.closed)
        }
    }

    func send(json: [String: Any]) {
        queue.async {
            guard let task = self.task else { return }
            do {
                let data = try ProtocolCodec.encode(json)
                let text = String(decoding: data, as: UTF8.self)
                task.send(.string(text)) { error in
                    if let error {
                        self.onState?(.failed(error))
                    }
                }
            } catch {
                self.onState?(.failed(error))
            }
        }
    }

    func ping(timestamp: Double = Date().timeIntervalSince1970) {
        send(json: [
            "type": "Ping",
            "t": timestamp
        ])
    }

    private func receiveLoop() {
        task?.receive { result in
            switch result {
            case .failure(let error):
                self.onState?(.failed(error))
            case .success(let msg):
                switch msg {
                case .string(let text):
                    if let data = text.data(using: .utf8), let envelope = ProtocolCodec.decodeEnvelope(from: data) {
                        self.onEnvelope?(envelope)
                    }
                case .data(let data):
                    if let envelope = ProtocolCodec.decodeEnvelope(from: data) {
                        self.onEnvelope?(envelope)
                    }
                @unknown default:
                    break
                }
                self.receiveLoop()
            }
        }
    }
}

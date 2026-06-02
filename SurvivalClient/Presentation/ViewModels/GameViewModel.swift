import Foundation
import Combine

final class GameViewModel: ObservableObject {
    @Published var playerId: String = ""
    @Published var connectionText: String = "Disconnected"
    @Published var hp: Double = 100
    @Published var hunger: Double = 100
    @Published var thirst: Double = 100
    @Published var stamina: Double = 100
    @Published var chat: [ChatMessage] = []
    @Published var nearbyTargets: [MiniMapTarget] = []
    @Published var inventoryItems: [InventoryItem] = []
    @Published var playerPosition: Vec2 = .init(x: 0, y: 0)
    @Published var dayTimeMinutes: Double = 12 * 60
    @Published var weatherKind: String = "clear"
    @Published var weatherIntensity: Double = 0

    private let socket = GameSocketClient()
    private var pingTimer: Timer?
    private var latestPosition = Vec2(x: 0, y: 0)

    var playerName: String = "Survivor"

    init() {
        socket.onState = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .idle: self?.connectionText = "Idle"
                case .connecting: self?.connectionText = "Connecting..."
                case .connected: self?.connectionText = "Connected"
                case .closed: self?.connectionText = "Closed"
                case .failed(let error): self?.connectionText = "Error: \(error.localizedDescription)"
                }
            }
        }

        socket.onEnvelope = { [weak self] env in
            self?.handleEnvelope(env)
        }
    }

    func connect(url: URL, name: String) {
        playerName = name
        socket.connect(url: url)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.socket.send(json: [
                "type": "Hello",
                "name": name
            ])
        }

        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.socket.ping()
        }
    }

    func disconnect() {
        pingTimer?.invalidate()
        pingTimer = nil
        socket.close()
    }

    func sendMovement(vx: Double, vy: Double, running: Bool, crouch: Bool = false, roll: Bool = false) {
        guard !playerId.isEmpty else { return }
        let action = running ? "run" : "walk"
        socket.send(json: [
            "type": "Movement",
            "playerId": playerId,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "position": ["x": latestPosition.x, "y": latestPosition.y],
            "velocity": ["x": vx, "y": vy],
            "action": action,
            "crouch": crouch,
            "roll": roll
        ])
    }

    func attack(targetId: String? = nil, weapon: String = "pistol") {
        guard !playerId.isEmpty else { return }
        var payload: [String: Any] = [
            "type": "Attack",
            "playerId": playerId,
            "weapon": weapon,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        if let targetId {
            payload["targetId"] = targetId
        }
        socket.send(json: payload)
    }

    func reload() {
        socket.send(json: ["type": "Reload"])
    }

    func use(itemId: String) {
        socket.send(json: ["type": "UseItem", "itemId": itemId])
    }

    func craft(recipeId: String) {
        socket.send(json: ["type": "Craft", "recipeId": recipeId])
    }

    func build(buildId: String, x: Double, y: Double) {
        socket.send(json: [
            "type": "Build",
            "buildId": buildId,
            "position": ["x": x, "y": y]
        ])
    }

    func sendChat(channel: String, text: String) {
        socket.send(json: [
            "type": "Chat",
            "channel": channel,
            "text": text
        ])
    }

    func vehicle(action: String, vehicleId: String? = nil, input: Vec2? = nil) {
        var payload: [String: Any] = ["type": "Vehicle", "action": action]
        if let vehicleId { payload["vehicleId"] = vehicleId }
        if let input {
            payload["input"] = ["x": input.x, "y": input.y]
        }
        socket.send(json: payload)
    }

    private func handleEnvelope(_ env: SocketEnvelope) {
        switch env.type {
        case "Welcome":
            handleWelcome(env)
        case "Snapshot":
            handleSnapshot(env)
        case "Delta":
            handleDelta(env)
        case "Chat":
            handleChat(env)
        case "Pong":
            break
        case "Error":
            if let err = env.error {
                print("Server error: \(err)")
            }
        default:
            break
        }
    }

    private func handleWelcome(_ env: SocketEnvelope) {
        let data = ProtocolCodec.decodeDictionary(from: env.data)
        if let dataValue = data["data"]?.objectValue,
           let pid = dataValue["playerId"]?.stringValue {
            DispatchQueue.main.async { self.playerId = pid }
        } else if let pid = data["playerId"]?.stringValue {
            DispatchQueue.main.async { self.playerId = pid }
        }
    }

    private func handleSnapshot(_ env: SocketEnvelope) {
        let root = ProtocolCodec.decodeDictionary(from: env.data)
        let you = root["you"]?.objectValue
        let stats = you?["stats"]?.objectValue
        let inv = you?["inventory"]?.objectValue

        DispatchQueue.main.async {
            if let hp = stats?["hp"]?.numberValue { self.hp = hp }
            if let hunger = stats?["hunger"]?.numberValue { self.hunger = hunger }
            if let thirst = stats?["thirst"]?.numberValue { self.thirst = thirst }
            if let stamina = stats?["stamina"]?.numberValue { self.stamina = stamina }

            if let pos = you?["position"]?.objectValue,
               let x = pos["x"]?.numberValue,
               let y = pos["y"]?.numberValue {
                let p = Vec2(x: x, y: y)
                self.latestPosition = p
                self.playerPosition = p
            }

            if let world = root["world"]?.objectValue {
                if let day = world["dayTimeMinutes"]?.numberValue { self.dayTimeMinutes = day }
                if let weather = world["weather"]?.objectValue {
                    if let kind = weather["kind"]?.stringValue { self.weatherKind = kind }
                    if let intensity = weather["intensity"]?.numberValue { self.weatherIntensity = intensity }
                }
            }

            if let invItems = inv?["items"]?.arrayValue {
                self.inventoryItems = invItems.compactMap { entry in
                    guard let obj = entry.objectValue,
                          let itemId = obj["itemId"]?.stringValue,
                          let qty = obj["qty"]?.numberValue else { return nil }
                    return InventoryItem(itemId: itemId, qty: Int(qty))
                }
            }
        }
    }

    private func handleDelta(_ env: SocketEnvelope) {
        let root = ProtocolCodec.decodeDictionary(from: env.data)
        if let players = root["players"]?.arrayValue {
            let mapped: [MiniMapTarget] = players.compactMap { value in
                guard let obj = value.objectValue,
                      let id = obj["id"]?.stringValue,
                      let pos = obj["position"]?.objectValue,
                      let x = pos["x"]?.numberValue,
                      let y = pos["y"]?.numberValue else { return nil }
                return MiniMapTarget(id: id, x: x, y: y, kind: "player")
            }

            DispatchQueue.main.async {
                self.nearbyTargets = mapped
                if let me = mapped.first(where: { $0.id == self.playerId }) {
                    let p = Vec2(x: me.x, y: me.y)
                    self.latestPosition = p
                    self.playerPosition = p
                }
            }
        }

        if let world = root["world"]?.objectValue {
            DispatchQueue.main.async {
                if let day = world["dayTimeMinutes"]?.numberValue { self.dayTimeMinutes = day }
                if let weather = world["weather"]?.objectValue {
                    if let kind = weather["kind"]?.stringValue { self.weatherKind = kind }
                    if let intensity = weather["intensity"]?.numberValue { self.weatherIntensity = intensity }
                }
            }
        }
    }

    private func handleChat(_ env: SocketEnvelope) {
        let root = ProtocolCodec.decodeDictionary(from: env.data)
        let data = root["data"]?.objectValue ?? root
        guard
            let id = data["id"]?.stringValue,
            let channel = data["channel"]?.stringValue,
            let fromName = data["fromName"]?.stringValue,
            let text = data["text"]?.stringValue,
            let timestamp = data["timestamp"]?.stringValue
        else { return }

        let message = ChatMessage(id: id, channel: channel, fromName: fromName, text: text, timestamp: timestamp)
        DispatchQueue.main.async {
            self.chat.append(message)
            if self.chat.count > 100 {
                self.chat.removeFirst(self.chat.count - 100)
            }
        }
    }
}

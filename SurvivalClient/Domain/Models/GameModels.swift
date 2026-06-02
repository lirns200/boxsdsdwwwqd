import Foundation
import CoreGraphics

struct MovementMessage: Codable {
    let type: String
    let playerId: String
    let timestamp: String
    let position: Vec2
    let velocity: Vec2
    let action: String
    let crouch: Bool?
    let roll: Bool?
}

struct AttackMessage: Codable {
    let type: String
    let playerId: String
    let targetId: String
    let weapon: String
    let hitPart: String
    let damage: Double
    let critical: Bool
    let timestamp: String
}

struct InventoryUpdateMessage: Codable {
    let type: String
    let playerId: String
    let items: [InventoryItem]
}

struct Vec2: Codable {
    var x: Double
    var y: Double
}

struct InventoryItem: Codable, Identifiable {
    var id: String { itemId }
    let itemId: String
    let qty: Int
}

struct ChatMessage: Identifiable {
    let id: String
    let channel: String
    let fromName: String
    let text: String
    let timestamp: String
}

struct MiniMapTarget: Identifiable {
    let id: String
    let x: Double
    let y: Double
    let kind: String
}

struct PlayerSnapshot: Codable, Identifiable {
    let id: String
    let name: String?
    let position: Vec2
    let hp: Double?
    let alive: Bool?
}

struct WorldDelta: Codable {
    let serverTime: String?
    let players: [PlayerSnapshot]?
}

import SwiftUI

final class AppState: ObservableObject {
    @Published var playerName: String = "Survivor"
    @Published var selectedServerURL: URL = URL(string: "ws://127.0.0.1:8080")!
    @Published var isConnected: Bool = false
    @Published var connectionLatencyMs: Int = 0

    @Published var hp: Double = 100
    @Published var hunger: Double = 100
    @Published var thirst: Double = 100
    @Published var stamina: Double = 100

    @Published var quickSlots: [String?] = ["pistol", "bandage", "apple", nil, nil, nil]
    @Published var chatMessages: [ChatMessage] = []
    @Published var minimapTargets: [MiniMapTarget] = []

    @Published var showInventory: Bool = false
    @Published var showCraft: Bool = false
    @Published var showSkills: Bool = false
    @Published var showSettings: Bool = false
}

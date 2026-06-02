import SwiftUI
import SpriteKit

struct GameContainerView: View {
    @ObservedObject var gameVM: GameViewModel
    let onExit: () -> Void

    @State private var joystickVector = CGVector(dx: 0, dy: 0)
    @State private var isRunning = false
    @State private var chatInput: String = ""
    @State private var selectedTab: OverlayTab = .inventory

    enum OverlayTab: String, CaseIterable {
        case inventory = "Инвентарь"
        case craft = "Крафт"
        case skills = "Навыки"
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                SpriteView(scene: GameScene.shared, options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .onAppear {
                        GameScene.shared.bind(viewModel: gameVM)
                    }

                VStack {
                    topHUD
                    Spacer()
                    bottomControls(isLandscape: isLandscape)
                }
                .padding(.horizontal, isLandscape ? 16 : 10)
                .padding(.vertical, isLandscape ? 8 : 12)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        overlayPanel
                            .frame(width: isLandscape ? 360 : 330, height: isLandscape ? 300 : 280)
                            .padding(.trailing, isLandscape ? 12 : 6)
                            .padding(.bottom, isLandscape ? 44 : 120)
                    }
                }

                VStack {
                    Spacer()
                    chatPanel
                }
                .padding(.bottom, isLandscape ? 6 : 8)
            }
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("ID: \(gameVM.playerId)")
                        .font(.caption)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Выйти", role: .destructive) {
                        onExit()
                    }
                }
            }
        }
    }

    private var topHUD: some View {
        HStack(spacing: 10) {
            StatusBar(title: "HP", value: gameVM.hp, max: 100, color: .red)
            StatusBar(title: "Голод", value: gameVM.hunger, max: 100, color: .orange)
            StatusBar(title: "Жажда", value: gameVM.thirst, max: 100, color: .blue)
            StatusBar(title: "Стамина", value: gameVM.stamina, max: 100, color: .green)
            Spacer()
            Text(gameVM.connectionText)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
                .foregroundColor(.white)
        }
    }

    private func bottomControls(isLandscape: Bool) -> some View {
        HStack(alignment: .bottom, spacing: isLandscape ? 14 : 8) {
            JoystickView(vector: $joystickVector) { vector in
                joystickVector = vector
                gameVM.sendMovement(vx: Double(vector.dx), vy: Double(-vector.dy), running: isRunning)
            }
            .frame(width: isLandscape ? 130 : 100, height: isLandscape ? 130 : 100)

            if isLandscape {
                HStack(spacing: 8) {
                    Button("Атака") { gameVM.attack() }
                        .buttonStyle(.borderedProminent)
                    Button("Перезарядка") { gameVM.reload() }
                        .buttonStyle(.bordered)
                    Toggle("Бег", isOn: $isRunning)
                        .toggleStyle(.button)
                    Button("Исп. бинт") { gameVM.use(itemId: "bandage") }
                        .buttonStyle(.bordered)
                    Button("Палатка") { gameVM.build(buildId: "tent", x: 10, y: 10) }
                        .buttonStyle(.bordered)
                }
                .font(.footnote)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 8) {
                    Button("Атака") { gameVM.attack() }
                        .buttonStyle(.borderedProminent)
                    Button("Перезарядка") { gameVM.reload() }
                        .buttonStyle(.bordered)
                    Toggle("Бег", isOn: $isRunning)
                        .toggleStyle(.button)
                    HStack {
                        Button("Исп. бинт") { gameVM.use(itemId: "bandage") }
                        Button("Палатка") { gameVM.build(buildId: "tent", x: 10, y: 10) }
                    }
                    .buttonStyle(.bordered)
                }
            }

            Spacer(minLength: 8)

            MiniMapView(targets: gameVM.nearbyTargets)
                .frame(width: isLandscape ? 140 : 160, height: isLandscape ? 140 : 160)
                .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))

            QuickSlotsView(items: gameVM.inventoryItems)
                .frame(width: isLandscape ? 180 : 220)
        }
    }

    private var overlayPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Tab", selection: $selectedTab) {
                ForEach(OverlayTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)

            switch selectedTab {
            case .inventory:
                InventoryPanel(items: gameVM.inventoryItems)
            case .craft:
                CraftPanel(onCraft: { recipe in gameVM.craft(recipeId: recipe) })
            case .skills:
                SkillsPanel()
            }
        }
        .padding(10)
        .background(.black.opacity(0.65), in: RoundedRectangle(cornerRadius: 12))
        .foregroundColor(.white)
    }

    private var chatPanel: some View {
        VStack(spacing: 6) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(gameVM.chat.suffix(6)) { msg in
                        Text("[\(msg.channel)] \(msg.fromName): \(msg.text)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 82)

            HStack {
                TextField("Сообщение...", text: $chatInput)
                    .textFieldStyle(.roundedBorder)
                Button("Global") {
                    let text = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    gameVM.sendChat(channel: "global", text: text)
                    chatInput = ""
                }
                Button("Local") {
                    let text = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    gameVM.sendChat(channel: "local", text: text)
                    chatInput = ""
                }
            }
        }
        .padding(8)
        .background(.black.opacity(0.65), in: RoundedRectangle(cornerRadius: 10))
        .foregroundColor(.white)
        .frame(maxWidth: 600)
    }
}

private struct StatusBar: View {
    let title: String
    let value: Double
    let max: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.9))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.15))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(Swift.min(Swift.max(value / max, 0), 1)))
                }
            }
            .frame(height: 8)
        }
        .frame(width: 120)
    }
}

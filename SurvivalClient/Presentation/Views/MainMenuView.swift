import SwiftUI

struct MainMenuView: View {
    @ObservedObject var menuVM: MenuViewModel
    let onPlay: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [.black, .gray.opacity(0.8), .green.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                let isLandscape = geo.size.width > geo.size.height

                if isLandscape {
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PIXEL SURVIVAL")
                                .font(.system(size: 42, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)

                            Text("2D PvE/PvP • iOS • Authoritative Server")
                                .foregroundColor(.white.opacity(0.82))

                            Spacer(minLength: 0)

                            HStack(spacing: 10) {
                                Button("Играть", action: onPlay)
                                    .buttonStyle(.borderedProminent)
                                    .tint(.green)
                                Button("Настройки") {}
                                    .buttonStyle(.bordered)
                                Button("Профиль") {}
                                    .buttonStyle(.bordered)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                        GroupBox("Профиль") {
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Ник", text: $menuVM.nickname)
                                    .textFieldStyle(.roundedBorder)
                                TextField("WebSocket URL", text: $menuVM.selectedServer)
                                    .textFieldStyle(.roundedBorder)
                                Picker("Регион", selection: $menuVM.serverRegion) {
                                    ForEach(menuVM.regions, id: \.self) { region in
                                        Text(region).tag(region)
                                    }
                                }
                            }
                            .padding(.top, 6)
                        }
                        .tint(.green)
                        .frame(width: min(420, geo.size.width * 0.38))
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 20)
                } else {
                    VStack(spacing: 16) {
                        Text("PIXEL SURVIVAL")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)

                        Text("2D PvE/PvP • iOS • Authoritative Server")
                            .foregroundColor(.white.opacity(0.8))

                        GroupBox("Профиль") {
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Ник", text: $menuVM.nickname)
                                    .textFieldStyle(.roundedBorder)
                                TextField("WebSocket URL", text: $menuVM.selectedServer)
                                    .textFieldStyle(.roundedBorder)
                                Picker("Регион", selection: $menuVM.serverRegion) {
                                    ForEach(menuVM.regions, id: \.self) { region in
                                        Text(region).tag(region)
                                    }
                                }
                            }
                            .padding(.top, 6)
                        }
                        .tint(.green)

                        HStack(spacing: 12) {
                            Button("Играть", action: onPlay)
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                            Button("Профиль") {}
                                .buttonStyle(.bordered)
                            Button("Друзья") {}
                                .buttonStyle(.bordered)
                            Button("Настройки") {}
                                .buttonStyle(.bordered)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 640)
                }
            }
        }
    }
}

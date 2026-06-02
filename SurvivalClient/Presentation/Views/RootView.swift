import SwiftUI

struct RootView: View {
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var menuVM = MenuViewModel()
    @State private var inGame: Bool = false

    var body: some View {
        Group {
            if inGame {
                GameContainerView(gameVM: gameVM, onExit: {
                    gameVM.disconnect()
                    inGame = false
                })
            } else {
                MainMenuView(menuVM: menuVM, onPlay: {
                    guard let url = URL(string: menuVM.selectedServer) else { return }
                    gameVM.connect(url: url, name: menuVM.nickname)
                    inGame = true
                })
            }
        }
    }
}

import SwiftUI

final class MenuViewModel: ObservableObject {
    @Published var selectedServer: String = "ws://127.0.0.1:8080"
    @Published var nickname: String = "Survivor"
    @Published var serverRegion: String = "Local"

    let regions = ["Local", "EU", "US", "ASIA"]
}

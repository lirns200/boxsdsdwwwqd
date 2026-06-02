import SpriteKit

final class DayNightWeatherSystem {
    private let darknessOverlay = SKSpriteNode(color: .black, size: CGSize(width: 8000, height: 8000))
    private let fogOverlay = SKSpriteNode(color: .gray, size: CGSize(width: 8000, height: 8000))

    func install(into scene: SKScene) {
        darknessOverlay.zPosition = 900
        darknessOverlay.alpha = 0.0
        fogOverlay.zPosition = 850
        fogOverlay.alpha = 0.0

        if darknessOverlay.parent == nil { scene.addChild(darknessOverlay) }
        if fogOverlay.parent == nil { scene.addChild(fogOverlay) }
    }

    func update(dayTimeMinutes: Double, weatherKind: String, intensity: Double) {
        let hour = dayTimeMinutes / 60.0
        if hour >= 20 || hour <= 5 {
            darknessOverlay.alpha = CGFloat(min(max(0.35 + intensity * 0.25, 0), 0.8))
        } else {
            darknessOverlay.alpha = 0.0
        }

        switch weatherKind {
        case "fog":
            fogOverlay.alpha = CGFloat(min(max(0.15 + intensity * 0.45, 0), 0.65))
        case "rain", "storm":
            fogOverlay.alpha = CGFloat(min(max(0.08 + intensity * 0.2, 0), 0.35))
        default:
            fogOverlay.alpha = 0.0
        }
    }
}

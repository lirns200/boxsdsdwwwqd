import SpriteKit

final class RoofOcclusionSystem {
    struct Building {
        let roofNode: SKNode
        let interiorFrame: CGRect
    }

    private var buildings: [Building] = []

    func register(roofNode: SKNode, interiorFrame: CGRect) {
        buildings.append(Building(roofNode: roofNode, interiorFrame: interiorFrame))
    }

    func update(playerPosition: CGPoint) {
        for building in buildings {
            let inside = building.interiorFrame.contains(playerPosition)
            let targetAlpha: CGFloat = inside ? 0.05 : 1.0
            if abs(building.roofNode.alpha - targetAlpha) > 0.01 {
                building.roofNode.run(.fadeAlpha(to: targetAlpha, duration: 0.15))
            }
        }
    }
}

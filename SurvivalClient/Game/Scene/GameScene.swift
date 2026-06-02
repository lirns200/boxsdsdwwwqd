import SpriteKit

final class GameScene: SKScene {
    static let shared = GameScene(size: CGSize(width: 2532, height: 1170))

    private weak var gameVM: GameViewModel?
    private let cameraNode = SKCameraNode()
    private let playerNode = SKSpriteNode(color: .green, size: CGSize(width: 32, height: 32))
    private var others: [String: SKSpriteNode] = [:]

    private let chunkSystem = ChunkStreamingSystem()
    private let roofSystem = RoofOcclusionSystem()
    private let dayNightSystem = DayNightWeatherSystem()

    private let worldSize = CGSize(width: 1000, height: 1000)

    private override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .aspectFill
        backgroundColor = SKColor(red: 0.10, green: 0.13, blue: 0.10, alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(viewModel: GameViewModel) {
        self.gameVM = viewModel
    }

    override func didMove(to view: SKView) {
        if camera == nil {
            addChild(cameraNode)
            camera = cameraNode
        }

        if playerNode.parent == nil {
            playerNode.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(playerNode)
        }

        drawGrid()
        installBuildingsForRoofDemo()
        dayNightSystem.install(into: self)
    }

    override func update(_ currentTime: TimeInterval) {
        guard let vm = gameVM else { return }

        let worldScale: CGFloat = 2.2

        let playerWorldPos = CGPoint(
            x: CGFloat(vm.playerPosition.x) * worldScale,
            y: CGFloat(vm.playerPosition.y) * worldScale
        )
        playerNode.position = playerWorldPos
        cameraNode.position = playerNode.position

        chunkSystem.update(center: playerWorldPos)
        roofSystem.update(playerPosition: playerWorldPos)
        dayNightSystem.update(dayTimeMinutes: vm.dayTimeMinutes, weatherKind: vm.weatherKind, intensity: vm.weatherIntensity)

        let seen = Set(vm.nearbyTargets.map { $0.id })

        for target in vm.nearbyTargets where target.id != vm.playerId {
            let node = others[target.id] ?? {
                let n = SKSpriteNode(color: .cyan, size: CGSize(width: 28, height: 28))
                n.zPosition = 10
                addChild(n)
                others[target.id] = n
                return n
            }()

            let x = CGFloat(target.x) * worldScale
            let y = CGFloat(target.y) * worldScale
            node.position = CGPoint(x: x, y: y)
        }

        for (id, node) in others where !seen.contains(id) {
            node.removeFromParent()
            others.removeValue(forKey: id)
        }
    }

    private func drawGrid() {
        let tileSize: CGFloat = 64
        let cols = Int(worldSize.width / 20)
        let rows = Int(worldSize.height / 20)

        for x in 0...cols {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: CGFloat(x) * tileSize, y: 0))
            path.addLine(to: CGPoint(x: CGFloat(x) * tileSize, y: CGFloat(rows) * tileSize))
            let line = SKShapeNode(path: path)
            line.strokeColor = .darkGray
            line.lineWidth = 0.5
            line.alpha = 0.35
            addChild(line)
        }

        for y in 0...rows {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: CGFloat(y) * tileSize))
            path.addLine(to: CGPoint(x: CGFloat(cols) * tileSize, y: CGFloat(y) * tileSize))
            let line = SKShapeNode(path: path)
            line.strokeColor = .darkGray
            line.lineWidth = 0.5
            line.alpha = 0.35
            addChild(line)
        }
    }

    private func installBuildingsForRoofDemo() {
        let buildingPositions: [CGPoint] = [
            CGPoint(x: 620, y: 710),
            CGPoint(x: 980, y: 1240),
            CGPoint(x: 1330, y: 860)
        ]

        for center in buildingPositions {
            let base = SKSpriteNode(color: .brown.withAlphaComponent(0.7), size: CGSize(width: 180, height: 130))
            base.position = center
            base.zPosition = 2
            addChild(base)

            let roof = SKSpriteNode(color: .gray, size: CGSize(width: 190, height: 140))
            roof.position = center
            roof.zPosition = 20
            addChild(roof)

            let interior = CGRect(x: center.x - 80, y: center.y - 55, width: 160, height: 110)
            roofSystem.register(roofNode: roof, interiorFrame: interior)
        }
    }
}

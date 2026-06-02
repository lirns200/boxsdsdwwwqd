import Foundation

struct AnimationClip {
    let key: String
    let frameSize: CGSizeString
    let frames: Int
    let frameDuration: Double
}

struct CGSizeString {
    let width: Int
    let height: Int
}

enum AnimationCatalog {
    static let hero: [AnimationClip] = [
        .init(key: "hero_idle", frameSize: .init(width: 64, height: 64), frames: 4, frameDuration: 0.1),
        .init(key: "hero_walk", frameSize: .init(width: 64, height: 64), frames: 4, frameDuration: 0.1),
        .init(key: "hero_run", frameSize: .init(width: 64, height: 64), frames: 6, frameDuration: 0.08),
        .init(key: "hero_melee", frameSize: .init(width: 64, height: 64), frames: 6, frameDuration: 0.08),
        .init(key: "hero_shoot", frameSize: .init(width: 64, height: 64), frames: 4, frameDuration: 0.07),
        .init(key: "hero_reload", frameSize: .init(width: 64, height: 64), frames: 6, frameDuration: 0.1)
    ]

    static let zombie: [AnimationClip] = [
        .init(key: "zombie_walk", frameSize: .init(width: 64, height: 64), frames: 4, frameDuration: 0.12),
        .init(key: "zombie_attack", frameSize: .init(width: 64, height: 64), frames: 6, frameDuration: 0.1),
        .init(key: "zombie_death", frameSize: .init(width: 64, height: 64), frames: 6, frameDuration: 0.09)
    ]

    static let fx: [AnimationClip] = [
        .init(key: "fx_fire", frameSize: .init(width: 32, height: 32), frames: 8, frameDuration: 0.09),
        .init(key: "fx_smoke", frameSize: .init(width: 32, height: 32), frames: 8, frameDuration: 0.11),
        .init(key: "fx_explosion", frameSize: .init(width: 64, height: 64), frames: 10, frameDuration: 0.06)
    ]
}

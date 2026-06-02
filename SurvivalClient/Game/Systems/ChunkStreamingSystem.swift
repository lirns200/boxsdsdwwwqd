import Foundation
import CoreGraphics

final class ChunkStreamingSystem {
    struct Chunk: Hashable {
        let x: Int
        let y: Int
    }

    private(set) var loadedChunks: Set<Chunk> = []
    var chunkSize: CGFloat = 256
    var viewRadiusChunks: Int = 2

    func update(center: CGPoint) {
        let cx = Int(floor(center.x / chunkSize))
        let cy = Int(floor(center.y / chunkSize))

        var next: Set<Chunk> = []
        for dx in -viewRadiusChunks...viewRadiusChunks {
            for dy in -viewRadiusChunks...viewRadiusChunks {
                next.insert(Chunk(x: cx + dx, y: cy + dy))
            }
        }

        loadedChunks = next
    }

    func shouldDraw(tileAt point: CGPoint) -> Bool {
        let tx = Int(floor(point.x / chunkSize))
        let ty = Int(floor(point.y / chunkSize))
        return loadedChunks.contains(Chunk(x: tx, y: ty))
    }
}

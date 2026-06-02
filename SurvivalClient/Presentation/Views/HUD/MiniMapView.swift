import SwiftUI

struct MiniMapView: View {
    let targets: [MiniMapTarget]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.5))
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .padding(10)

                ForEach(targets.prefix(32)) { t in
                    Circle()
                        .fill(colorFor(kind: t.kind))
                        .frame(width: 5, height: 5)
                        .position(x: normalized(t.x, max: 1000) * geo.size.width,
                                  y: normalized(t.y, max: 1000) * geo.size.height)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func normalized(_ value: Double, max upperBound: Double) -> CGFloat {
        CGFloat(Swift.min(Swift.max(value / upperBound, 0), 1))
    }

    private func colorFor(kind: String) -> Color {
        switch kind {
        case "player": return .green
        case "zombie": return .red
        case "boss": return .purple
        default: return .white
        }
    }
}

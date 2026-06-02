import SwiftUI

struct JoystickView: View {
    @Binding var vector: CGVector
    var onChanged: (CGVector) -> Void

    @State private var dragOffset: CGSize = .zero
    private let radius: CGFloat = 48

    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.45))
                .frame(width: radius * 2.2, height: radius * 2.2)

            Circle()
                .fill(.white.opacity(0.3))
                .frame(width: 34, height: 34)
                .offset(dragOffset)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let dx = value.translation.width
                    let dy = value.translation.height
                    let dist = sqrt(dx * dx + dy * dy)
                    if dist <= radius {
                        dragOffset = value.translation
                    } else {
                        let scale = radius / dist
                        dragOffset = CGSize(width: dx * scale, height: dy * scale)
                    }

                    let vx = Double(dragOffset.width / radius)
                    let vy = Double(dragOffset.height / radius)
                    vector = CGVector(dx: vx, dy: vy)
                    onChanged(vector)
                }
                .onEnded { _ in
                    dragOffset = .zero
                    vector = .zero
                    onChanged(.zero)
                }
        )
    }
}

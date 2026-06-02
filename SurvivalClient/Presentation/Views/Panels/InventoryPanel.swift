import SwiftUI

struct InventoryPanel: View {
    let items: [InventoryItem]

    private let columns = Array(repeating: GridItem(.flexible(minimum: 44, maximum: 70), spacing: 6), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Инвентарь (drag & drop каркас)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))

            ScrollView {
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(items) { item in
                        VStack(spacing: 2) {
                            Text(item.itemId)
                                .font(.system(size: 9, weight: .semibold))
                                .lineLimit(1)
                            Text("x\(item.qty)")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
        }
    }
}

import SwiftUI

struct QuickSlotsView: View {
    let items: [InventoryItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Быстрые слоты")
                .font(.caption)
                .foregroundColor(.white)

            HStack(spacing: 6) {
                ForEach(0..<6, id: \.self) { idx in
                    let item = idx < items.count ? items[idx] : nil
                    VStack(spacing: 2) {
                        Text(item?.itemId ?? "—")
                            .font(.system(size: 9, weight: .medium))
                            .lineLimit(1)
                        Text(item != nil ? "x\(item!.qty)" : "")
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 34, height: 34)
                    .padding(4)
                    .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
                    .overlay(alignment: .topLeading) {
                        Text("\(idx + 1)")
                            .font(.system(size: 8, weight: .bold))
                            .padding(2)
                            .background(.black.opacity(0.65), in: RoundedRectangle(cornerRadius: 4))
                            .foregroundColor(.white)
                            .offset(x: 2, y: 2)
                    }
                }
            }
        }
    }
}

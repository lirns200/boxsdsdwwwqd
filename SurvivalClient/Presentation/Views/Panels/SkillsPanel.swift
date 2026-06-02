import SwiftUI

struct SkillsPanel: View {
    private let rows: [(String, Int)] = [
        ("Стрельба", 1),
        ("Выживание", 1),
        ("Медицина", 1),
        ("Кузнечное", 1),
        ("Кулинария", 1),
        ("Вождение", 1)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Навыки")
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))

            ForEach(rows, id: \.0) { row in
                HStack {
                    Text(row.0)
                    Spacer()
                    Text("Lv \(row.1)")
                        .foregroundColor(.green)
                }
                .font(.callout)
            }

            Spacer()
        }
    }
}

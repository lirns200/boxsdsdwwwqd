import SwiftUI

struct CraftPanel: View {
    let onCraft: (String) -> Void

    private let recipes = [
        ("Дубинка", "club"),
        ("Мачете", "machete"),
        ("Копьё", "spear"),
        ("Бинт", "bandage")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Крафт")
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))

            ForEach(recipes, id: \.1) { recipe in
                HStack {
                    Text(recipe.0)
                    Spacer()
                    Button("Создать") { onCraft(recipe.1) }
                        .buttonStyle(.bordered)
                }
            }

            Spacer()
        }
    }
}

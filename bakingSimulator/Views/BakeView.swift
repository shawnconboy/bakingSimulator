import SwiftUI

struct BakeView: View {
    @EnvironmentObject var gameManager: GameManager

    // Sample recipes for now
    let sampleRecipes = [
        Recipe(name: "Chocolate Chip Cookies", ingredients: ["Flour": 2, "Sugar": 1, "Eggs": 1], bakeTime: 5, salePrice: 10),
        Recipe(name: "Cupcakes", ingredients: ["Flour": 3, "Sugar": 2, "Eggs": 2], bakeTime: 8, salePrice: 15)
    ]

    @State private var bakingItem: String? = nil
    @State private var bakeProgress: Double = 0.0
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Text("Select a Recipe to Bake")
                .font(.headline)
                .padding(.top)

            ForEach(sampleRecipes, id: \.name) { recipe in
                VStack {
                    Text(recipe.name)
                        .font(.title2)

                    Button("Bake") {
                        startBaking(recipe: recipe)
                    }
                    .disabled(bakingItem != nil)
                }
                .padding()
            }

            if let bakingItem = bakingItem {
                VStack {
                    Text("Baking: \(bakingItem)")
                    ProgressView(value: bakeProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding()
                }
            }
        }
        .padding()
    }

    func startBaking(recipe: Recipe) {
        bakingItem = recipe.name
        bakeProgress = 0.0

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            bakeProgress += 0.1 / recipe.bakeTime
            if bakeProgress >= 1.0 {
                t.invalidate()
                gameManager.inventory[recipe.name, default: 0] += 1
                bakingItem = nil
            }
        }
    }
}

import Foundation

struct Ingredient: Identifiable {
    let id = UUID()
    let name: String
    var quantity: Int
    let cost: Double
}

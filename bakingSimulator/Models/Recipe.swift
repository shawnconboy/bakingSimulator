import Foundation

struct Recipe {
    let name: String
    let ingredients: [String: Int] // Ingredient name → quantity
    let bakeTime: TimeInterval
    let salePrice: Double
}

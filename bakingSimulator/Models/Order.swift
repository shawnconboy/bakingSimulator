import Foundation

struct Order: Identifiable {
    let id = UUID()
    let recipeName: String
    let quantity: Int
    let reward: Double
    var isCompleted: Bool
}

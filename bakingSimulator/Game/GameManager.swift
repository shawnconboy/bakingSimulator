import Foundation
import SwiftUI

class GameManager: ObservableObject {
    @Published var coins: Double = 100.0
    @Published var ingredients: [Ingredient] = []
    @Published var inventory: [String: Int] = [:]
    @Published var orders: [Order] = []
}

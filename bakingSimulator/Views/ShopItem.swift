import Foundation

struct ShopItem: Identifiable {
    var id = UUID()
    var name: String
    var price: Int
    var maxQuantity: Int
}


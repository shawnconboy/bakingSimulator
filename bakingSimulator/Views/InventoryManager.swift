import Foundation

class InventoryManager: ObservableObject {
    static let shared = InventoryManager()

    @Published var money: Int = 0
    @Published var items: [String: Int] = [:]

    private init() { }

    func addItem(_ item: String, quantity: Int = 1) {
        items[item, default: 0] += quantity
    }

    func removeItem(_ item: String, quantity: Int = 1) {
        if let current = items[item], current >= quantity {
            items[item] = current - quantity
            if items[item] == 0 {
                items.removeValue(forKey: item)
            }
        }
    }

    func spendMoney(_ amount: Int) {
        if money >= amount {
            money -= amount
        }
    }

    func earnMoney(_ amount: Int) {
        money += amount
    }
}

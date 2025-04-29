import SwiftUI

struct ShopMenuView: View {
    @ObservedObject var inventory = InventoryManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var cart: [ShopItem] = []

    let shopItems: [ShopItem] = [
        ShopItem(name: "Flour", price: 2, maxQuantity: 10),
        ShopItem(name: "Sugar", price: 2, maxQuantity: 8),
        ShopItem(name: "Chocolate Chips", price: 3, maxQuantity: 6),
        ShopItem(name: "Baking Powder", price: 1, maxQuantity: 5),
        ShopItem(name: "Butter", price: 2, maxQuantity: 6)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("💵 Money: $\(inventory.money)")
                    .font(.title2.bold())
                    .padding(.top)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(shopItems) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text("$\(item.price)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    cart.append(item)
                                }) {
                                    Text("Add to Cart")
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 20)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                    }
                }

                if !cart.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🛒 Cart:")
                            .font(.headline)
                        ForEach(cart.indices, id: \.self) { idx in
                            let cartItem = cart[idx]
                            HStack {
                                Text("\(cartItem.name) - $\(cartItem.price)")
                                Spacer()
                                Button(action: {
                                    cart.remove(at: idx)
                                }) {
                                    Image(systemName: "trash").foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                            .onTapGesture {
                                cart.remove(at: idx)
                            }
                        }
                        Button(action: {
                            let total = cart.reduce(0) { $0 + $1.price }
                            if inventory.money >= total {
                                for item in cart {
                                    inventory.purchaseItem(item: item.name, price: item.price)
                                }
                                cart.removeAll()
                            }
                        }) {
                            Text("Buy All ($\(cart.reduce(0) { $0 + $1.price }))")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 24)
                                .background(inventory.money >= cart.reduce(0) { $0 + $1.price } ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(cart.isEmpty || inventory.money < cart.reduce(0) { $0 + $1.price })
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }

                Button("Close Shop") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.red)
                .padding()
            }
            .navigationTitle("🛍️ Shop")
            .navigationBarHidden(true)
        }
    }
}

import SwiftUI

struct InventoryView: View {
    @ObservedObject var inventory = InventoryManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Money Display
            VStack(alignment: .leading, spacing: 4) {
                Text("Money")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("$\(inventory.money)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 5)

            // Items Display
            Text("Inventory")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            

            if inventory.items.isEmpty {
                VStack {
                    Spacer()
                    Text("Your bag is empty!")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(inventory.items.sorted(by: { $0.key < $1.key }), id: \.key) { item, quantity in
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.tertiarySystemBackground))
                                    .frame(height: 80)
                                    .overlay(
                                        VStack(spacing: 4) {
                                            Text(item)
                                                .font(.headline)
                                            Text("x\(quantity)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
        .navigationTitle("Inventory")
    }
}

#Preview {
    InventoryView()
}

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Welcome to Baking Simulator!")
                .font(.largeTitle)
                .padding()
            Text("Manage your bakery, bake goods, and fulfill customer orders.")
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

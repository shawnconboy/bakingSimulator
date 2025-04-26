import SwiftUI

struct HomeView: View {
    @AppStorage("playerXP") var playerXP: Int = 0
    @AppStorage("playerLevel") var playerLevel: Int = 1

    let xpMilestones = [1000, 2500, 5000, 10000, 20000]

    var xpForNextLevel: Int {
        playerLevel <= xpMilestones.count ? xpMilestones[playerLevel - 1] : xpMilestones.last ?? 20000
    }

    var xpProgress: Double {
        Double(playerXP) / Double(xpForNextLevel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Level and XP Display
                VStack(spacing: 10) {
                    Text("Level \(playerLevel)")
                        .font(.largeTitle)
                        .bold()

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 20)
                            .foregroundColor(Color.gray.opacity(0.3))

                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: CGFloat(xpProgress) * UIScreen.main.bounds.width * 0.8, height: 20)
                            .foregroundColor(.green)
                            .animation(.easeInOut(duration: 0.5), value: xpProgress)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8)

                    Text("\(playerXP) / \(xpForNextLevel) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()

                Divider()

                // Welcome Text
                VStack(spacing: 10) {
                    Text("Welcome to Baking Simulator!")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("Manage your bakery, bake goods, and fulfill customer orders. Level up by exploring and completing missions!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
        }
    }
}

import SwiftUI

struct HomeView: View {
    @AppStorage("playerXP") var playerXP: Int = 0

    // XP milestones for each level
    let xpMilestones = [0, 1000, 2500, 5000, 10000]

    // Calculate level
    var currentLevel: Int {
        for i in 1..<xpMilestones.count {
            if playerXP < xpMilestones[i] {
                return i
            }
        }
        return xpMilestones.count
    }

    var xpForCurrentLevel: Int {
        xpMilestones[currentLevel - 1]
    }

    var xpForNextLevel: Int {
        xpMilestones[currentLevel]
    }

    var xpProgress: Double {
        Double(playerXP - xpForCurrentLevel) / Double(xpForNextLevel - xpForCurrentLevel)
    }

    var body: some View {
        VStack(spacing: 20) {
            // XP + Level tracker
            VStack(alignment: .leading, spacing: 8) {
                Text("Level \(currentLevel)")
                    .font(.headline)

                ProgressView(value: xpProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .frame(height: 12)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)

                Text("\(playerXP - xpForCurrentLevel) / \(xpForNextLevel - xpForCurrentLevel) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            Text("Welcome to Baking Simulator!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top)

            Text("Manage your bakery, bake goods, and fulfill customer orders.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

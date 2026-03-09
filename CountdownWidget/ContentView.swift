import SwiftUI

struct ContentView: View {
    @ObservedObject var manager: CountdownManager

    var body: some View {
        VStack(spacing: 16) {
            GridView(currentDay: manager.currentDay)

            VStack(spacing: 4) {
                Text(dayLabel)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                if !manager.endDateFormatted.isEmpty {
                    Text("Ends \(manager.endDateFormatted)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(20)
        .frame(width: 420)
    }

    private var dayLabel: String {
        if manager.currentDay <= 0 {
            return "Starts soon"
        } else if manager.currentDay > 100 {
            return "Completed!"
        } else {
            return "DAY \(manager.currentDay) of 100"
        }
    }
}



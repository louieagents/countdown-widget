import SwiftUI

struct GridView: View {
    let currentDay: Int
    private let columns = Array(repeating: GridItem(.fixed(34), spacing: 4), count: 10)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(1...100, id: \.self) { day in
                DaySquare(day: day, state: stateFor(day: day))
            }
        }
    }

    private func stateFor(day: Int) -> DayState {
        if day < currentDay {
            return .completed
        } else if day == currentDay {
            return .today
        } else {
            return .remaining
        }
    }
}

enum DayState {
    case completed
    case today
    case remaining
}

struct DaySquare: View {
    let day: Int
    let state: DayState

    @State private var pulseOpacity: Double = 1.0

    private let completedColor = Color(red: 0.902, green: 0.224, blue: 0.275) // #E63946
    private let outlineColor = Color(white: 0.2)

    var body: some View {
        ZStack {
            switch state {
            case .completed:
                RoundedRectangle(cornerRadius: 4)
                    .fill(completedColor)
                    .frame(width: 34, height: 34)

            case .today:
                RoundedRectangle(cornerRadius: 4)
                    .fill(completedColor)
                    .frame(width: 34, height: 34)
                    .opacity(pulseOpacity)
                    .shadow(color: completedColor.opacity(0.7), radius: 6)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            pulseOpacity = 0.5
                        }
                    }

            case .remaining:
                RoundedRectangle(cornerRadius: 4)
                    .stroke(outlineColor, lineWidth: 1.5)
                    .frame(width: 34, height: 34)
            }

            Text("\(day)")
                .font(.system(size: 9, weight: state == .remaining ? .regular : .medium, design: .rounded))
                .foregroundColor(state == .remaining ? .white.opacity(0.3) : .white.opacity(0.85))
        }
    }
}



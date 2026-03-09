import Foundation
import Combine

class CountdownManager: ObservableObject {
    private static let startDateKey = "CountdownStartDate"

    @Published var startDate: Date? {
        didSet {
            if let startDate {
                UserDefaults.standard.set(startDate.timeIntervalSince1970, forKey: Self.startDateKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.startDateKey)
            }
        }
    }

    @Published private(set) var currentDay: Int = 0
    private var timer: Timer?

    init() {
        let stored = UserDefaults.standard.double(forKey: Self.startDateKey)
        if stored > 0 {
            self.startDate = Date(timeIntervalSince1970: stored)
        }
        updateCurrentDay()
        scheduleMidnightTimer()
    }

    func updateCurrentDay() {
        guard let startDate else {
            currentDay = 0
            return
        }
        let calendar = Calendar.current
        let startOfStart = calendar.startOfDay(for: startDate)
        let startOfToday = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: startOfStart, to: startOfToday).day ?? 0
        // Day 1 is the start date itself, clamped to 0...100
        currentDay = min(max(days + 1, 0), 100)
    }

    var endDate: Date? {
        guard let startDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: 99, to: startDate)
    }

    var endDateFormatted: String {
        guard let endDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: endDate)
    }

    private func scheduleMidnightTimer() {
        // Fire a timer every 60 seconds to check for day change
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateCurrentDay()
        }
    }
}

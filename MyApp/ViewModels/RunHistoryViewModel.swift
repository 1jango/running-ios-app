import Foundation

struct RunHistoryViewModel {
    static func sessionsThisWeek(from sessions: [RunSession], calendar: Calendar = .current) -> [RunSession] {
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else {
            return []
        }
        return sessions.filter { $0.startDate >= weekStart }
    }

    static func totalDistanceMeters(of sessions: [RunSession]) -> Double {
        sessions.reduce(0) { runningTotal, session in runningTotal + session.totalDistanceMeters }
    }
}

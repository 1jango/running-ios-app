import Foundation
import SwiftData

@Model
final class Lap {
    var number: Int
    var distanceMeters: Double
    var durationSeconds: Double
    var startDate: Date
    var endDate: Date
    var session: RunSession?

    init(number: Int, distanceMeters: Double, durationSeconds: Double, startDate: Date, endDate: Date) {
        self.number = number
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.startDate = startDate
        self.endDate = endDate
    }

    var paceSecondsPerKm: Double {
        guard distanceMeters > 0 else { return 0 }
        return durationSeconds / (distanceMeters / 1000)
    }
}

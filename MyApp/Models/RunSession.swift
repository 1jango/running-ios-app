import Foundation
import SwiftData

@Model
final class RunSession {
    var startDate: Date
    var endDate: Date?
    var totalDistanceMeters: Double
    var totalDurationSeconds: Double

    // Cascade: deleting a RunSession deletes its laps and route points too.
    @Relationship(deleteRule: .cascade, inverse: \Lap.session)
    var laps: [Lap] = []

    @Relationship(deleteRule: .cascade, inverse: \RoutePoint.session)
    var routePoints: [RoutePoint] = []

    init(startDate: Date) {
        self.startDate = startDate
        self.endDate = nil
        self.totalDistanceMeters = 0
        self.totalDurationSeconds = 0
    }

    var averagePaceSecondsPerKm: Double {
        guard totalDistanceMeters > 0 else { return 0 }
        return totalDurationSeconds / (totalDistanceMeters / 1000)
    }
}

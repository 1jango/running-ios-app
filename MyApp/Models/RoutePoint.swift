import Foundation
import SwiftData
import CoreLocation

@Model
final class RoutePoint {
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var speed: Double
    var session: RunSession?

    init(timestamp: Date, latitude: Double, longitude: Double, altitude: Double, speed: Double) {
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.speed = speed
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

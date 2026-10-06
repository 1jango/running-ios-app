import Foundation
import CoreLocation

final class LocationTrackingService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    var onLocationUpdate: ((CLLocation) -> Void)?
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .fitness

        // Required for GPS updates to keep arriving after the screen locks.
        manager.allowsBackgroundLocationUpdates = true

        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
    }

    func requestAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    func startTracking() {
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
    }

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            onLocationUpdate?(location)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorizationChange?(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationTrackingService error: \(error.localizedDescription)")
    }
}

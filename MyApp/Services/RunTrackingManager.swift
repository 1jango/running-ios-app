import Foundation
import CoreLocation
import SwiftData
import Observation

@Observable
final class RunTrackingManager {
    private(set) var isTracking = false
    private(set) var isPaused = false
    private(set) var totalDistanceMeters: Double = 0
    private(set) var elapsedSeconds: TimeInterval = 0
    private(set) var completedLaps: [Lap] = []
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationService = LocationTrackingService()
    private let speechAnnouncer = SpeechAnnouncerService()

    // 1000 = announce every kilometer; 1609 would switch to miles.
    private let lapDistanceMeters: Double = 1000

    private var lastLocation: CLLocation?
    private var distanceSinceLastLap: Double = 0
    private var currentLapStartDate = Date()
    private var runStartDate = Date()
    private var pausedDurationTotal: TimeInterval = 0
    private var pauseStartedAt: Date?
    private var timer: Timer?
    private var activeSession: RunSession?
    private var bufferedRoutePoints: [RoutePoint] = []

    init() {
        // [weak self] avoids a self -> locationService -> closure -> self cycle.
        locationService.onLocationUpdate = { [weak self] location in
            self?.handle(newLocation: location)
        }
        locationService.onAuthorizationChange = { [weak self] status in
            self?.authorizationStatus = status
        }
    }

    func requestPermissions() {
        locationService.requestAuthorization()
    }

    func start() {
        guard !isTracking else { return }

        runStartDate = Date()
        currentLapStartDate = runStartDate
        pausedDurationTotal = 0
        pauseStartedAt = nil
        totalDistanceMeters = 0
        elapsedSeconds = 0
        distanceSinceLastLap = 0
        completedLaps = []
        bufferedRoutePoints = []
        lastLocation = nil
        activeSession = RunSession(startDate: runStartDate)

        isTracking = true
        isPaused = false

        locationService.startTracking()
        startTimer()
    }

    func pause() {
        guard isTracking, !isPaused else { return }
        isPaused = true
        pauseStartedAt = Date()
        timer?.invalidate()
    }

    func resume() {
        guard isTracking, isPaused else { return }
        if let pauseStartedAt {
            pausedDurationTotal += Date().timeIntervalSince(pauseStartedAt)
        }
        pauseStartedAt = nil
        isPaused = false
        startTimer()
    }

    @discardableResult
    func finish(savingTo context: ModelContext) -> RunSession? {
        guard isTracking, let session = activeSession else { return nil }

        if distanceSinceLastLap > 0 {
            closeLap(distance: distanceSinceLastLap, announce: false)
        }

        timer?.invalidate()
        locationService.stopTracking()

        session.endDate = Date()
        session.totalDistanceMeters = totalDistanceMeters
        session.totalDurationSeconds = elapsedSeconds
        session.laps = completedLaps
        session.routePoints = bufferedRoutePoints

        context.insert(session)
        do {
            try context.save()
        } catch {
            print("RunTrackingManager: failed to save run session: \(error)")
        }

        isTracking = false
        isPaused = false
        activeSession = nil

        return session
    }

    private func handle(newLocation: CLLocation) {
        guard isTracking, !isPaused else { return }

        // Ignore fixes with no/poor accuracy (indoors, under cover, etc).
        guard newLocation.horizontalAccuracy >= 0, newLocation.horizontalAccuracy < 50 else {
            return
        }

        bufferedRoutePoints.append(
            RoutePoint(
                timestamp: newLocation.timestamp,
                latitude: newLocation.coordinate.latitude,
                longitude: newLocation.coordinate.longitude,
                altitude: newLocation.altitude,
                speed: newLocation.speed
            )
        )

        defer { lastLocation = newLocation }

        guard let previous = lastLocation else { return }

        let delta = newLocation.distance(from: previous)
        guard delta > 0 else { return }

        totalDistanceMeters += delta
        distanceSinceLastLap += delta

        if distanceSinceLastLap >= lapDistanceMeters {
            // Carry the overflow past 1000m into the next lap.
            let overflow = distanceSinceLastLap - lapDistanceMeters
            closeLap(distance: lapDistanceMeters, announce: true)
            distanceSinceLastLap = overflow
        }
    }

    private func closeLap(distance: Double, announce: Bool) {
        let now = Date()
        let lap = Lap(
            number: completedLaps.count + 1,
            distanceMeters: distance,
            durationSeconds: now.timeIntervalSince(currentLapStartDate),
            startDate: currentLapStartDate,
            endDate: now
        )
        completedLaps.append(lap)
        currentLapStartDate = now

        if announce {
            speechAnnouncer.speak(buildAnnouncement(for: lap))
        }
    }

    private func buildAnnouncement(for lap: Lap) -> String {
        let overallPaceSecondsPerKm = totalDistanceMeters > 0
            ? elapsedSeconds / (totalDistanceMeters / 1000)
            : 0

        let lapPace = Formatters.spokenPace(secondsPerKm: lap.paceSecondsPerKm)
        let overallPace = Formatters.spokenPace(secondsPerKm: overallPaceSecondsPerKm)
        let lapTime = Formatters.spokenDuration(seconds: lap.durationSeconds)
        let totalTime = Formatters.spokenDuration(seconds: elapsedSeconds)
        let totalKm = String(format: "%.1f", totalDistanceMeters / 1000)

        return """
        Kilometer \(lap.number) complete. Lap time \(lapTime), lap pace \(lapPace) per kilometer. \
        Total distance \(totalKm) kilometers in \(totalTime). Average pace \(overallPace) per kilometer.
        """
    }

    private func startTimer() {
        timer?.invalidate()
        // Recomputed from dates each tick so a delayed tick can't cause drift.
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds = Date().timeIntervalSince(self.runStartDate) - self.pausedDurationTotal
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
}

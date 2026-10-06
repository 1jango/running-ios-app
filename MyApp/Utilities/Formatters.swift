import Foundation

enum Formatters {
    static func clock(seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds.rounded())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }

    // Spelled out in words since AVSpeechSynthesizer reads "5:12" awkwardly.
    static func spokenDuration(seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds.rounded())
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        if minutes == 0 {
            return "\(secs) seconds"
        }
        return "\(minutes) minutes \(secs) seconds"
    }

    static func spokenPace(secondsPerKm: Double) -> String {
        guard secondsPerKm.isFinite, secondsPerKm > 0 else { return "unknown" }
        return spokenDuration(seconds: secondsPerKm)
    }

    static func distance(meters: Double) -> String {
        String(format: "%.2f km", meters / 1000)
    }

    static func pace(secondsPerKm: Double) -> String {
        guard secondsPerKm.isFinite, secondsPerKm > 0 else { return "--:--" }
        return "\(clock(seconds: secondsPerKm)) /km"
    }
}

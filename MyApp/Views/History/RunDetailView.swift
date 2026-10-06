import SwiftUI

struct RunDetailView: View {
    let session: RunSession

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Date", value: session.startDate.formatted(date: .long, time: .shortened))
                LabeledContent("Distance", value: Formatters.distance(meters: session.totalDistanceMeters))
                LabeledContent("Duration", value: Formatters.clock(seconds: session.totalDurationSeconds))
                LabeledContent("Average Pace", value: Formatters.pace(secondsPerKm: session.averagePaceSecondsPerKm))
            }

            Section("Laps") {
                // SwiftData doesn't guarantee relationship-array order.
                ForEach(session.laps.sorted { $0.number < $1.number }) { lap in
                    LapRowView(lap: lap)
                }
            }
        }
        .navigationTitle("Run Details")
    }
}

import SwiftUI

struct RunSummaryView: View {
    let session: RunSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Summary") {
                    LabeledContent("Distance", value: Formatters.distance(meters: session.totalDistanceMeters))
                    LabeledContent("Duration", value: Formatters.clock(seconds: session.totalDurationSeconds))
                    LabeledContent("Average Pace", value: Formatters.pace(secondsPerKm: session.averagePaceSecondsPerKm))
                }

                Section("Laps") {
                    ForEach(session.laps.sorted { $0.number < $1.number }) { lap in
                        LapRowView(lap: lap)
                    }
                }
            }
            .navigationTitle("Run Complete")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

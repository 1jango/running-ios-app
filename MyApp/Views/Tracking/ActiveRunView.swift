import SwiftUI
import SwiftData

struct ActiveRunView: View {
    @State private var tracker = RunTrackingManager()
    @Environment(\.modelContext) private var modelContext
    @State private var finishedSession: RunSession?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text(Formatters.distance(meters: tracker.totalDistanceMeters))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                HStack(spacing: 40) {
                    statBlock(title: "Time", value: Formatters.clock(seconds: tracker.elapsedSeconds))
                    statBlock(title: "Avg Pace", value: Formatters.pace(secondsPerKm: averagePaceSecondsPerKm))
                    statBlock(title: "Laps", value: "\(tracker.completedLaps.count)")
                }

                controls

                if !tracker.completedLaps.isEmpty {
                    List(tracker.completedLaps.reversed()) { lap in
                        LapRowView(lap: lap)
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Run")
            .task {
                tracker.requestPermissions()
            }
            .sheet(item: $finishedSession) { session in
                RunSummaryView(session: session)
            }
        }
    }

    private var averagePaceSecondsPerKm: Double {
        guard tracker.totalDistanceMeters > 0 else { return 0 }
        return tracker.elapsedSeconds / (tracker.totalDistanceMeters / 1000)
    }

    @ViewBuilder
    private var controls: some View {
        if !tracker.isTracking {
            Button {
                tracker.start()
            } label: {
                Label("Start Run", systemImage: "play.fill")
                    .font(.title2.bold())
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        } else {
            HStack(spacing: 20) {
                Button {
                    if tracker.isPaused {
                        tracker.resume()
                    } else {
                        tracker.pause()
                    }
                } label: {
                    Label(
                        tracker.isPaused ? "Resume" : "Pause",
                        systemImage: tracker.isPaused ? "play.fill" : "pause.fill"
                    )
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    finishedSession = tracker.finish(savingTo: modelContext)
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .font(.title2.bold())
        }
    }

    private func statBlock(title: String, value: String) -> some View {
        VStack {
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ActiveRunView()
        .modelContainer(for: RunSession.self, inMemory: true)
}

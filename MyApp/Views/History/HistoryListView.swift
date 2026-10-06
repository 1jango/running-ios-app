import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Query(sort: \RunSession.startDate, order: .reverse) private var sessions: [RunSession]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                if !thisWeekSessions.isEmpty {
                    Section("This Week") {
                        LabeledContent("Runs", value: "\(thisWeekSessions.count)")
                        LabeledContent(
                            "Distance",
                            value: Formatters.distance(meters: RunHistoryViewModel.totalDistanceMeters(of: thisWeekSessions))
                        )
                    }
                }

                Section("All Runs") {
                    ForEach(sessions) { session in
                        NavigationLink {
                            RunDetailView(session: session)
                        } label: {
                            RunSummaryRow(session: session)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("History")
            .overlay {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Runs Yet",
                        systemImage: "figure.run.circle",
                        description: Text("Finish a run on the Track tab and it'll show up here.")
                    )
                }
            }
        }
    }

    private var thisWeekSessions: [RunSession] {
        RunHistoryViewModel.sessionsThisWeek(from: sessions)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
}

private struct RunSummaryRow: View {
    let session: RunSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline.bold())
            HStack {
                Text(Formatters.distance(meters: session.totalDistanceMeters))
                Text("·")
                Text(Formatters.clock(seconds: session.totalDurationSeconds))
                Text("·")
                Text(Formatters.pace(secondsPerKm: session.averagePaceSecondsPerKm))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HistoryListView()
        .modelContainer(for: RunSession.self, inMemory: true)
}

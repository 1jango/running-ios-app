import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Track", systemImage: "figure.run") {
                ActiveRunView()
            }
            Tab("History", systemImage: "clock.arrow.circlepath") {
                HistoryListView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: RunSession.self, inMemory: true)
}

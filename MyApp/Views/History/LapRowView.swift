import SwiftUI

struct LapRowView: View {
    let lap: Lap

    var body: some View {
        HStack {
            Text("Km \(lap.number)")
                .font(.headline)
                .frame(width: 60, alignment: .leading)

            Text(Formatters.clock(seconds: lap.durationSeconds))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(Formatters.pace(secondsPerKm: lap.paceSecondsPerKm))
                .foregroundStyle(.secondary)
        }
    }
}

import SwiftUI

struct IngestionGauge: View {

    let name: String
    let minValue = 0.0
    let maxValue = 1.0
    var currentValue: Double {
        guard currentTime >= startTime else {return 0}
        guard currentTime <= endTime else {return 1}
        let total = startTime.distance(to: endTime)
        let distanceFromStart = startTime.distance(to: currentTime)
        return distanceFromStart / total
    }
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let startTime: Date
    let endTime: Date
    @State private var currentTime: Date

    let gradientStops: Gradient

    init(ingestion: Ingestion) {
        self.name = ingestion.substanceCopy?.nameUnwrapped ?? "Unknown"
        self.startTime = ingestion.timeUnwrapped
        let durations = ingestion.substanceCopy?.getDuration(for: ingestion.administrationRouteUnwrapped)

        let onsetDuration = durations?.onset?.oneValue(at: 0.5) ?? 0
        let comeupDuration = durations?.comeup?.oneValue(at: 0.5) ?? 0
        let peakDuration = durations?.peak?.oneValue(at: ingestion.horizontalWeight) ?? 0
        let offsetDuration = durations?.offset?.oneValue(at: ingestion.horizontalWeight) ?? 0

        var totalTime = onsetDuration + comeupDuration + peakDuration + offsetDuration
        if totalTime == 0 {
            totalTime = 5*60*60
        }

        self.endTime = ingestion.timeUnwrapped.addingTimeInterval(totalTime)

        let onsetStartLocation = CGFloat(onsetDuration / totalTime)
        let peakStartLocation = CGFloat((onsetDuration + comeupDuration) / totalTime)
        let peakEndLocation = CGFloat((onsetDuration + comeupDuration + peakDuration) / totalTime)

        self.gradientStops = Gradient(
            stops: [
                .init(color: .white.opacity(0.2), location: onsetStartLocation),
                .init(color: ingestion.swiftUIColorUnwrapped, location: peakStartLocation),
                .init(color: ingestion.swiftUIColorUnwrapped, location: peakEndLocation),
                .init(color: .white.opacity(0.2), location: 1)
        ])

        self._currentTime = State(wrappedValue: Date())
    }

    var body: some View {
        Gauge(value: currentValue, in: minValue...maxValue) {
            Text(name)
        } currentValueLabel: {
            Text(currentTime.asTimeString)
        } minimumValueLabel: {
            Text(startTime.asTimeString)
        } maximumValueLabel: {
            Text(endTime.asTimeString)
        }
        .gaugeStyle(LinearGaugeStyle(tint: gradientStops))
        .onReceive(timer) { _ in
            withAnimation {
                currentTime = Date()
            }
        }
    }
}

struct IngestionGauge_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        IngestionGauge(ingestion: helper.experiences.first!.sortedIngestionsUnwrapped.first!)
    }
}

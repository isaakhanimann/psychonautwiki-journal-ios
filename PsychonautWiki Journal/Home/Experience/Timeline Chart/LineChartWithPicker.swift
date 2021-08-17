import SwiftUI

struct LineChartWithPicker: View {

    let sortedIngestions: [Ingestion]

    @AppStorage("timeStep") var selectedTimeStep: Double = ChartTimeStep.halfHour.rawValue

    var selectedTimeStepNotDouble: ChartTimeStep {
        ChartTimeStep(rawValue: selectedTimeStep) ?? ChartTimeStep.halfHour
    }

    var body: some View {
        VStack {
            IngestionsLineChart(
                sortedIngestions: sortedIngestions,
                timeStep: selectedTimeStepNotDouble
            )
            Picker("Timestep", selection: $selectedTimeStep.animation()) {
                Text("0.5 hours").tag(ChartTimeStep.halfHour.rawValue)
                Text("1 hour").tag(ChartTimeStep.oneHour.rawValue)
                Text("2 hours").tag(ChartTimeStep.twoHours.rawValue)
                Text("3 hours").tag(ChartTimeStep.threeHours.rawValue)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
        }
    }
}

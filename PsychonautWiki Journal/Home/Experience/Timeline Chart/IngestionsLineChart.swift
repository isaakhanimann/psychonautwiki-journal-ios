import SwiftUI

struct IngestionsLineChart: View {

    private let lineModels: [IngestionLineModel]
    private let chartWidth: CGFloat
    private let numberOfSteps: Double
    private let graphStartTime: Date
    private var graphEndTime: Date
    private let stepSize: CGFloat = 100
    private let timeStep: ChartTimeStep
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    @State private var currentTime = Date()
    @State private var relativeScrollPosition: Double?

    private let innerHorizontalPadding: CGFloat = 30
    private let chartHeight: CGFloat = 200

    var body: some View {
        RelativeScrollView(
            relativeScrollPosition: $relativeScrollPosition,
            childWidth: chartWidth + innerHorizontalPadding
        ) {
            VStack(alignment: .leading) {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color.gray.opacity(0.1))
                        .frame(width: chartWidth, height: chartHeight)

                    ForEach(0..<lineModels.count, id: \.self) { index in
                        LineView( ingestionLineModel: lineModels[index])
                    }
                    .frame(width: chartWidth, height: chartHeight)

                    if isCurrentTimeInChart {
                        CurrentTimeView(
                            currentTime: currentTime,
                            graphStartTime: graphStartTime,
                            graphEndTime: graphEndTime
                        )
                        .frame(width: chartWidth, height: 235)
                        .onAppear {
                            scrollToCurrentTime()
                        }
                        .onChange(of: timeStep) { _ in
                            scrollToCurrentTime()
                        }
                    }
                }
                TimeLabels(
                    timeStep: timeStep,
                    numberOfSteps: numberOfSteps,
                    startTime: graphStartTime,
                    stepSize: stepSize
                )
                .position(x: 0, y: 20)
                .frame(width: chartWidth, height: 45)
            }

            .padding(.horizontal, innerHorizontalPadding)
            .padding(.vertical, 10)
            .onReceive(timer) { newTime in
                currentTime = newTime
            }
        }
    }

    var isCurrentTimeInChart: Bool {
        currentTime > graphStartTime && currentTime < graphEndTime
    }

    init(
        sortedIngestions: [Ingestion],
        timeStep: ChartTimeStep = ChartTimeStep.halfHour
    ) {
        assert(!sortedIngestions.isEmpty)

        self.timeStep = timeStep
        self.graphStartTime = sortedIngestions.first!.timeUnwrapped
        self.graphEndTime = HelperMethods.getEndOfGraphTime(ingestions: sortedIngestions)

        let lengthOfGraphInSec = graphStartTime.distance(to: graphEndTime)
        self.numberOfSteps = lengthOfGraphInSec / timeStep.inSeconds()
        self.chartWidth = CGFloat(numberOfSteps) * stepSize

        self.lineModels = HelperMethods.getLineModels(sortedIngestions: sortedIngestions)
    }

    private func scrollToCurrentTime() {
        let graphLength = graphStartTime.distance(to: graphEndTime)
        let timeFromStart = graphStartTime.distance(to: currentTime)
        relativeScrollPosition = Double(timeFromStart) / Double(graphLength)
    }
}

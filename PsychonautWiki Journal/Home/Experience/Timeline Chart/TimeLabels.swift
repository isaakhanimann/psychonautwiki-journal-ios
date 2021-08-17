import SwiftUI

struct TimeLabels: View {

    let timeStep: ChartTimeStep
    let numberOfSteps: Double
    let startTime: Date
    let stepSize: CGFloat

    func getTimeLabel(for stepIndex: Int) -> some View {
        let xOffset = CGFloat(stepIndex) * stepSize

        var timeLabel = ""
        switch timeStep {
        case .halfHour:
            let isEven = stepIndex.isMultiple(of: 2)
            timeLabel = String(format: "%.\(isEven ? "0" : "1")fh", Double(stepIndex)*0.5)
        case .oneHour:
            timeLabel = "\(stepIndex)h"
        case .twoHours:
            timeLabel = "\(stepIndex*2)h"
        case .threeHours:
            timeLabel = "\(stepIndex*3)h"
        }

        return VStack {
            Text(timeLabel)
            Text(getTimeString(for: stepIndex))
        }
        .offset(x: xOffset, y: 0)
        .animation(nil)
    }

    func getTimeString(for labelNumber: Int) -> String {
        let secondsToPosition: TimeInterval = Double(labelNumber) * timeStep.inSeconds()
        let time: Date = startTime.addingTimeInterval(secondsToPosition)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }

    var body: some View {
        ZStack {
            ForEach(0...Int(numberOfSteps), id: \.self) { stepIndex in
                getTimeLabel(for: stepIndex)
            }
        }
    }
}

import SwiftUI

struct IngestionTimeLineView: View {

    let viewModel: ViewModel

    init(sortedIngestions: [Ingestion]) {
        self.viewModel = ViewModel(sortedIngestions: sortedIngestions)
    }

    var body: some View {
        GeometryReader { geoOut in
            VStack {
                GeometryReader { geoIn in
                    ZStack(alignment: .bottom) {
                        ForEach(0..<viewModel.lineModels.count, id: \.self) { index in
                            LineView(
                                ingestionLineModel: viewModel.lineModels[index],
                                graphStartTime: viewModel.startTime,
                                graphEndTime: viewModel.endTime
                            )
                        }
                        .frame(width: geoOut.size.width, height: geoIn.size.height)
                        CurrentTimeView(
                            startTime: viewModel.startTime,
                            endTime: viewModel.endTime
                        )
                            .frame(width: geoOut.size.width, height: geoIn.size.height)
                    }
                }
                TimeLabels(
                    startTime: viewModel.startTime,
                    endTime: viewModel.endTime,
                    totalWidth: geoOut.size.width
                )
                    .position(x: 0, y: 0)
                    .frame(width: geoOut.size.width)
                    .padding(.top, 5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TimeLineContent_Previews: PreviewProvider {
    static var previews: some View {
        List {
            IngestionTimeLineView(sortedIngestions: PreviewHelper.shared.experiences.first!.sortedIngestionsUnwrapped)
                .frame(height: 300)
        }
    }
}

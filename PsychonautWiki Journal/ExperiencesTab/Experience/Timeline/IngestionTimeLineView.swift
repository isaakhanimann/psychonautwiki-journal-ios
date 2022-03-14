import SwiftUI

struct IngestionTimeLineView: View {

    @ObservedObject var experience: Experience
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        GeometryReader { geoOut in
            VStack {
                if let startTime = viewModel.startTime, let endTime = viewModel.endTime {
                    GeometryReader { geoIn in
                        ZStack(alignment: .bottom) {
                            ForEach(0..<viewModel.ingestionContexts.count, id: \.self) { index in
                                LineView(
                                    ingestionWithTimelineContext: viewModel.ingestionContexts[index],
                                    ingestion: viewModel.ingestionContexts[index].ingestion
                                )
                            }
                            .frame(width: geoOut.size.width, height: geoIn.size.height)
                            CurrentTimeView(
                                startTime: startTime,
                                endTime: endTime
                            )
                                .frame(width: geoOut.size.width, height: geoIn.size.height)
                        }
                    }
                    TimeLabels(
                        startTime: startTime,
                        endTime: endTime,
                        totalWidth: geoOut.size.width
                    )
                        .position(x: 0, y: 0)
                        .frame(width: geoOut.size.width)
                        .padding(.top, 5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .task {
            viewModel.setupFetchRequestPredicateAndFetch(experience: experience)
        }
    }
}

struct TimeLineContent_Previews: PreviewProvider {
    static var previews: some View {
        List {
            IngestionTimeLineView(experience: PreviewHelper.shared.experiences.first!)
                .frame(height: 300)
        }
    }
}

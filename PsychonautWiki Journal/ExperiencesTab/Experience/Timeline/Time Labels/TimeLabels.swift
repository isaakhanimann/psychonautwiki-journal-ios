import SwiftUI

struct TimeLabels: View {

    let viewModel: ViewModel?

    init(
        startTime: Date,
        endTime: Date,
        totalWidth: Double
    ) {
        self.viewModel = ViewModel(startTime: startTime, endTime: endTime, totalWidth: totalWidth)
    }

    var body: some View {
        ZStack {
            if let viewModelUnwrap = viewModel {
                ForEach(viewModelUnwrap.labels) { label in
                    Text(label.text)
                        .offset(x: label.xOffset, y: 0)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
        }
    }
}

struct TimeLabels_Previews: PreviewProvider {
    static var previews: some View {
        TimeLabels(startTime: Date(), endTime: Date().addingTimeInterval(5*60*60), totalWidth: 300)
    }
}

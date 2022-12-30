import SwiftUI
import Charts

struct StatsScreen: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) var ingestions: FetchedResults<Ingestion>

    var body: some View {
        //StatsScreenContent()
        Text("Hello")
    }
}

//struct StatsScreenContent: View {
//
//
//    @State private var timeOption: TimeOption = .month12
//    var body: some View {
//        if #available(iOS 16, *) {
//            VStack {
//                Picker("Time Range", selection: $timeOption.animation(.easeInOut)) {
//                    ForEach(TimeOption.allCases) { option in
//                        Text(option.rawValue).tag(option)
//                    }
//                }.pickerStyle(.segmented)
//                GroupBox("Total Experiences") {
//                    Chart {
//                        BarMark(
//                            x: .value("Month", Date(), unit: .month),
//                            y: .value("Sales", 5)
//                        ).foregroundStyle(.green)
//                    }
//                }
//            }.padding(.horizontal)
//            .navigationTitle("Statistics")
//        }
//    }
//}

//struct SubstanceSummary: Identifiable {
//    var id: String {
//        substanceName
//    }
//    let substanceName: String
//    let color: Color
//    let count: Int
//    let month: Date
//}
//
//enum TimeOption: String, CaseIterable, Identifiable {
//    var id: String {
//        rawValue
//    }
//    case days7 = "7D"
//    case days30 = "30D"
//    case week20 = "20W"
//    case month12 = "12M"
//    case quarter8 = "8Q"
//    case year10 = "10Y"
//}

//struct StatsScreenContent_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            StatsScreenContent()
//        }
//    }
//}

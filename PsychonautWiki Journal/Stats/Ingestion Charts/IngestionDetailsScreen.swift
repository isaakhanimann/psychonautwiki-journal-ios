// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import Charts
import SwiftUI


@available(iOS 16, *)
struct IngestionDetailsScreen: View {

    let ingestionData: IngestionData
    @State private var timeRange: TimeRange = .last12Months

    var data: [IngestionCount] {
        switch timeRange {
        case .last30Days:
            return ingestionData.last30Days
        case .last12Months:
            return ingestionData.last12Months
        case .years:
            return ingestionData.years
        }
    }

    var body: some View {
        List {
            TimeRangePicker(value: $timeRange)
                .padding(.vertical, 5)
            if let maxCount = data.first?.ingestionCount {
                ForEach(data) { elem in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(elem.substanceName)
                                .font(.headline)
                            Spacer()
                            Text("\(elem.ingestionCount) Ingestions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        let widthRatio = Double(elem.ingestionCount) / Double(maxCount)
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(ingestionData.colorMapping(elem.substanceName))
                                .cornerRadius(5, corners: [.topRight, .bottomRight])
                                .frame(
                                    width: geometry.size.width*widthRatio
                                )
                        }
                        .frame(height: 20)
                    }
                }
            } else {
                Text("No Ingestions").font(.headline)
            }
        }
        .navigationTitle("Substances")
        .dismissWhenTabTapped()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

@available(iOS 16, *)
struct IngestionDetails_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IngestionDetailsScreen(ingestionData: .mock2)
                .environmentObject(TabBarObserver())
        }
    }
}

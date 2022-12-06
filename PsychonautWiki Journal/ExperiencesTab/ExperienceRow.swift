import SwiftUI
import Combine

struct ExperienceRow: View {

    @ObservedObject var experience: Experience

    var body: some View {
        return NavigationLink(
            destination: ExperienceView(experience: experience)
        ) {
            HStack {
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(
                                colors: getDoubleColors(from: experience.ingestionColors)),
                            center: .center
                        )
                    )
                    .frame(width: 35, height: 35)
                Spacer()
                    .frame(width: 10)
                VStack(alignment: .leading) {
                    Text(experience.titleUnwrapped)
                        .font(.title2)
                    if experience.distinctUsedSubstanceNames.isEmpty {
                        Text("No substance yet")
                            .foregroundColor(.secondary)
                    } else {
                        Text(experience.distinctUsedSubstanceNames, format: .list(type: .and))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .badge(Text(experience.dateForSorting, format: Date.FormatStyle().day().month()))
        }
    }

    private func getDoubleColors(from colors: [Color]) -> [Color] {
        var doubleColors = colors.flatMap { color in
            Array(repeating: color, count: 2)
        }
        if let firstColor = experience.ingestionColors.first {
            doubleColors.append(firstColor)
        }
        return doubleColors
    }
}

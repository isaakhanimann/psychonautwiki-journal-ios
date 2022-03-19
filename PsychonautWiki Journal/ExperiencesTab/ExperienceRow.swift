import SwiftUI
import Combine

struct ExperienceRow: View {

    @ObservedObject var experience: Experience
    @Binding var selection: Experience?

    var body: some View {

        return NavigationLink(
            destination: ExperienceView(experience: experience),
            tag: experience,
            selection: $selection
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
                    Text(!experience.usedSubstanceNames.isEmpty ? experience.usedSubstanceNames : "No substance yet")
                        .foregroundColor(.secondary)
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

struct ExperienceRow_Previews: PreviewProvider {

    static var previews: some View {
        List {
            ExperienceRow(
                experience: PreviewHelper.shared.experiences.first!,
                selection: .constant(nil)
            )
        }
    }
}

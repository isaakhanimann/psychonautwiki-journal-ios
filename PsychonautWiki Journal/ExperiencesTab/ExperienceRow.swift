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
                    .frame(width: 40, height: 40)
                Spacer()
                    .frame(width: 10)
                VStack(alignment: .leading) {
                    Text(experience.titleUnwrapped)
                        .font(.headline)
                    Text(!experience.usedSubstanceNames.isEmpty ? experience.usedSubstanceNames : "No substance yet")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(experience.timeOfFirstIngestion?.asDateNumberString ?? "")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
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

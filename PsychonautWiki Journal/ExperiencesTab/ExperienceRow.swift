import SwiftUI
import Combine

struct ExperienceRow: View {

    @ObservedObject var experience: Experience
    let isTimeRelative: Bool

    var body: some View {
        return NavigationLink(
            destination: ExperienceScreen(experience: experience)
        ) {
            ExperienceRowContent(
                ingestionColors: experience.ingestionColors,
                title: experience.titleUnwrapped,
                distinctSubstanceNames: experience.distinctUsedSubstanceNames,
                sortDate: experience.sortDateUnwrapped,
                isTimeRelative: isTimeRelative
            )
        }
    }
}

struct ExperienceRowContent: View {

    let ingestionColors: [Color]
    let title: String
    let distinctSubstanceNames: [String]
    let sortDate: Date
    let isTimeRelative: Bool

    var body: some View {
        HStack {
            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(
                            colors: getDoubleColors()),
                        center: .center
                    )
                )
                .frame(width: 35, height: 35)
            Spacer()
                .frame(width: 10)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                if distinctSubstanceNames.isEmpty {
                    Text("No substance")
                        .font(.subheadline)
                } else {
                    Text(distinctSubstanceNames, format: .list(type: .and))
                        .font(.subheadline)
                }
            }
        }
        .badge(isTimeRelative ? Text(sortDate, style: .relative) + Text(" ago") : Text(sortDate, format: Date.FormatStyle().day().month().year(.twoDigits)))
    }

    private func getDoubleColors() -> [Color] {
        var doubleColors = ingestionColors.flatMap { color in
            Array(repeating: color, count: 2)
        }
        if let firstColor = ingestionColors.first {
            doubleColors.append(firstColor)
        }
        return doubleColors
    }
}

struct ExperienceRowContent_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                ExperienceRowContent(
                    ingestionColors: [.blue, .pink],
                    title: "My title is not is a normal length",
                    distinctSubstanceNames: ["MDMA", "LSD"],
                    sortDate: Date() - 5 * 60 * 60 - 30,
                    isTimeRelative: false
                )
            }
        }
    }
}

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
                isFavorite: experience.isFavorite,
                isTimeRelative: isTimeRelative
            ).swipeActions(allowsFullSwipe: false) {
                Button(role: .destructive) {
                    PersistenceController.shared.viewContext.delete(experience)
                    PersistenceController.shared.saveViewContext()
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
        }
    }
}

struct ExperienceRowContent: View {

    let ingestionColors: [Color]
    let title: String
    let distinctSubstanceNames: [String]
    let sortDate: Date
    let isFavorite: Bool
    let isTimeRelative: Bool

    var body: some View {
        TimelineView(.everyMinute) { _ in
            rowWithoutBadge
                .badge(timeText)
        }
    }

    var rowWithoutBadge: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(
                                colors: getDoubleColors()),
                            center: .center
                        )
                    )
                    .frame(width: 35, height: 35)
                if isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
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
    }

    var timeText: Text {
        if isTimeRelative {
            return Text(getTimeDifferenceText())
        } else {
            return Text(sortDate, format: Date.FormatStyle().day().month().year(.twoDigits))
        }
    }

    func getTimeDifferenceText() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: sortDate, relativeTo: Date.now)
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
                    isFavorite: true,
                    isTimeRelative: true
                )
            }
        }
    }
}

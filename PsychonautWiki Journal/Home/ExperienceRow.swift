import SwiftUI
import Combine

struct ExperienceRow: View {

    @ObservedObject var experience: Experience
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @Binding var selection: Experience?

    var body: some View {
        NavigationLink(
            destination: ExperienceView(experience: experience),
            tag: experience,
            selection: $selection
        ) {
            HStack {
                Text(experience.titleUnwrapped)
                    .fixedSize()
                Spacer()
                if experience.isActive {
                    TimerView(experience: experience, timer: timer)
                } else {
                    ForEach(experience.sortedIngestionsUnwrapped) { ingestion in
                        Image(systemName: "circle.fill")
                            .font(.body)
                            .foregroundColor(ingestion.swiftUIColorUnwrapped)
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .clipped()
        }
    }
}

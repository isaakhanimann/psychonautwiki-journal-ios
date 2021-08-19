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
                ColorPie(colors: experience.ingestionColors)
                    .frame(width: 40)
                Spacer()
                    .frame(width: 10)
                VStack(alignment: .leading) {
                    Text(experience.titleUnwrapped)
                        .font(.title2)
                    Text(experience.usedSubstanceNames)
                        .foregroundColor(.gray)
                }
                Spacer()
                if experience.isActive {
                    TimerView(experience: experience, timer: timer)
                } else {
                    Text(experience.timeOfFirstIngestion?.asDateNumberString ?? "")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct ExperienceRow_Previews: PreviewProvider {

    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        ExperienceRow(
            experience: helper.experiences.first!,
            timer: timer,
            selection: .constant(nil)
        )
    }
}

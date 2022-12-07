import SwiftUI

struct OneRoaDurationRow: View {

    let duration: RoaDuration

    var body: some View {
        VStack {
            HStack {
                if let onset = duration.onset?.displayString {
                    DurationChip(name: "onset", text: onset)
                }
                if let comeup = duration.comeup?.displayString {
                    DurationChip(name: "comeup", text: comeup)
                }
                if let peak = duration.peak?.displayString {
                    DurationChip(name: "peak", text: peak)
                }
                if let offset = duration.offset?.displayString {
                    DurationChip(name: "offset", text: offset)
                }
            }
            HStack {
                if let total = duration.total?.displayString {
                    Text("total: \(total)")
                }
                Spacer()
                if let afterglow = duration.afterglow?.displayString {
                    Text("after effects: \(afterglow)")
                }
            }
        }
        .font(.footnote)
    }
}

struct DurationChip: View {
    let name: String
    let text: String

    var body: some View {
        VStack {
            Text(text)
            Text(name)
        }.padding(5)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
    }
}

struct DurationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section {
                    OneRoaDurationRow(
                        duration: SubstanceRepo.shared.getSubstance(name: "MDMA")!.getDuration(for: .oral)!
                    )
                }
            }
        }
    }
}

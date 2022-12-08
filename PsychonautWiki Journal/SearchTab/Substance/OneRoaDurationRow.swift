import SwiftUI

struct OneRoaDurationRow: View {

    let duration: RoaDuration
    let color: Color

    var body: some View {
        VStack {
            HStack {
                if let onset = duration.onset?.displayString {
                    DurationChip(name: "onset", text: onset, color: color)
                }
                if let comeup = duration.comeup?.displayString {
                    DurationChip(name: "comeup", text: comeup, color: color)
                }
                if let peak = duration.peak?.displayString {
                    DurationChip(name: "peak", text: peak, color: color)
                }
                if let offset = duration.offset?.displayString {
                    DurationChip(name: "offset", text: offset, color: color)
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
    let color: Color

    var body: some View {
        VStack {
            Text(text)
            Text(name)
        }.padding(5)
            .background(color.opacity(shapeOpacity))
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
                        duration: SubstanceRepo.shared.getSubstance(name: "MDMA")!.getDuration(for: .oral)!,
                        color: .blue
                    )
                }
            }
        }
    }
}

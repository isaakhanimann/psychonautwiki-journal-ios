import SwiftUI

struct OneRoaDurationRow: View {

    let duration: RoaDuration
    let color: SubstanceColor

    var body: some View {
        VStack {
            HStack {
                if let onset = duration.onset?.displayString {
                    DurationChip(name: "onset", text: onset, color: color)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }
                if let comeup = duration.comeup?.displayString {
                    DurationChip(name: "comeup", text: comeup, color: color)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }
                if let peak = duration.peak?.displayString {
                    DurationChip(name: "peak", text: peak, color: color)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }
                if let offset = duration.offset?.displayString {
                    DurationChip(name: "offset", text: offset, color: color)
                } else {
                    Spacer().frame(maxWidth: .infinity)
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
    let color: SubstanceColor

    var body: some View {
        VStack {
            Text(text)
            Text(name)
        }.padding(5)
            .background(color.swiftUIColor.opacity(shapeOpacity))
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
                        duration: SubstanceRepo.shared.getSubstance(name: "4-HO-MET")!.getDuration(for: .smoked)!,
                        color: .blue
                    )
                }
            }
        }
    }
}

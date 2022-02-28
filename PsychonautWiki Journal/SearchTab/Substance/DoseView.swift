import SwiftUI

struct DoseView: View {

    let roaDose: RoaDose?
    var threshOrLightMin: String {
        if let thresh = roaDose?.thresholdUnwrapped?.cleanString {
            return thresh
        } else if let lightMin = roaDose?.lightUnwrapped?.min.cleanString {
            return lightMin
        } else {
            return "..."
        }
    }
    var lightMaxOrCommonMin: String {
        if let lightMax = roaDose?.lightUnwrapped?.max.cleanString {
            return lightMax
        } else if let commonMin = roaDose?.commonUnwrapped?.min.cleanString {
            return commonMin
        } else {
            return "..."
        }
    }
    var commonMaxOrStrongMin: String {
        if let commonMax = roaDose?.commonUnwrapped?.max.cleanString {
            return commonMax
        } else if let strongMin = roaDose?.strongUnwrapped?.min.cleanString {
            return strongMin
        } else {
            return "..."
        }
    }
    var strongMaxOrHeavy: String {
        if let strongMax = roaDose?.strongUnwrapped?.max.cleanString {
            return strongMax
        } else if let heavy = roaDose?.heavyUnwrapped?.cleanString {
            return heavy
        } else {
            return "..."
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                Text(threshOrLightMin)
                Text("thresh ")
                    .font(.footnote)
            }
            .foregroundColor(.blue)
            VStack {
                Text("-")
                Text("light")
                    .font(.footnote)
            }
            .foregroundColor(.green)
            Text(lightMaxOrCommonMin)
                .foregroundLinearGradient(colors: [.green, .yellow])
            VStack {
                Text("-")
                Text("common")
                    .font(.footnote)
            }
            .foregroundColor(.yellow)
            Text(commonMaxOrStrongMin)
                .foregroundLinearGradient(colors: [.yellow, .orange])
            VStack {
                Text("-")
                Text("strong")
                    .font(.footnote)
            }
            .foregroundColor(.orange)
            Text(strongMaxOrHeavy)
                .foregroundLinearGradient(colors: [.orange, .red])
            VStack {
                Text("- ...")
                Text("heavy")
                    .font(.footnote)
            }
            .foregroundColor(.red)
            Text(roaDose?.units ?? "")
        }
    }
}

struct DoseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                List {
                    let dose = PreviewHelper().getSubstance(with: "Caffeine")!.roasUnwrapped.first!.dose!
                    Section {
                        DoseView(roaDose: dose)
                            .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
                    }
                }
            }
        }
    }
}

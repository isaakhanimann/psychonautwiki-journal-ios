import SwiftUI

struct DoseView: View {

    let roaDose: RoaDose?
    private var threshOrLightMin: String {
        if let thresh = roaDose?.thresholdUnwrapped?.cleanString {
            return thresh
        } else if let lightMin = roaDose?.lightUnwrapped?.min.cleanString {
            return lightMin
        } else {
            return "..."
        }
    }
    private var lightMaxOrCommonMin: String {
        if let lightMax = roaDose?.lightUnwrapped?.max.cleanString {
            return lightMax
        } else if let commonMin = roaDose?.commonUnwrapped?.min.cleanString {
            return commonMin
        } else {
            return "..."
        }
    }
    private var commonMaxOrStrongMin: String {
        if let commonMax = roaDose?.commonUnwrapped?.max.cleanString {
            return commonMax
        } else if let strongMin = roaDose?.strongUnwrapped?.min.cleanString {
            return strongMin
        } else {
            return "..."
        }
    }
    private var strongMaxOrHeavy: String {
        if let strongMax = roaDose?.strongUnwrapped?.max.cleanString {
            return strongMax
        } else if let heavy = roaDose?.heavyUnwrapped?.cleanString {
            return heavy
        } else {
            return "..."
        }
    }
    private let threshColor = Color.blue
    private let lightColor = Color.green
    private let commonColor = Color.yellow
    private let strongColor = Color.orange
    private let heavyColor = Color.red

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                Text(threshOrLightMin)
                    .foregroundLinearGradient(colors: [threshColor, lightColor])
                Text("thresh ")
                    .foregroundColor(threshColor)
                    .font(.footnote)
            }
            VStack {
                Text("-")
                Text("light")
                    .font(.footnote)
            }
            .foregroundColor(lightColor)
            Text(lightMaxOrCommonMin)
                .foregroundLinearGradient(colors: [lightColor, commonColor])
            VStack {
                Text("-")
                Text("common")
                    .font(.footnote)
            }
            .foregroundColor(commonColor)
            Text(commonMaxOrStrongMin)
                .foregroundLinearGradient(colors: [commonColor, strongColor])
            VStack {
                Text("-")
                Text("strong")
                    .font(.footnote)
            }
            .foregroundColor(strongColor)
            Text(strongMaxOrHeavy)
                .foregroundLinearGradient(colors: [strongColor, heavyColor])
            VStack {
                Text("- ...")
                Text("heavy")
                    .font(.footnote)
            }
            .foregroundColor(heavyColor)
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
                            .preferredColorScheme(.light)
                    }
                }
            }
        }
    }
}

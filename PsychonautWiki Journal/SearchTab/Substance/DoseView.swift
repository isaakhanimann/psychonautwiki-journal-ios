import SwiftUI

struct DoseView: View {

    let roaDose: RoaDose?
    private var threshOrLightMin: String? {
        if let thresh = roaDose?.thresholdUnwrapped?.cleanString {
            return thresh
        } else {
            return roaDose?.light?.min.cleanString
        }
    }
    private var lightMaxOrCommonMin: String? {
        if let lightMax = roaDose?.light?.max.cleanString {
            return lightMax
        } else {
            return roaDose?.common?.min.cleanString
        }
    }
    private var commonMaxOrStrongMin: String? {
        if let commonMax = roaDose?.common?.max.cleanString {
            return commonMax
        } else {
            return roaDose?.strong?.min.cleanString
        }
    }
    private var strongMaxOrHeavy: String? {
        if let strongMax = roaDose?.strong?.max.cleanString {
            return strongMax
        } else {
            return roaDose?.heavyUnwrapped?.cleanString
        }
    }
    var doseFont: Font {
        if let lightMaxOrCommonMinUnwrap = lightMaxOrCommonMin, lightMaxOrCommonMinUnwrap.count >= 4 {
            return .footnote
        } else if let commonMaxOrStrongMinUnwrap = commonMaxOrStrongMin, commonMaxOrStrongMinUnwrap.count >= 4 {
            return .footnote
        } else {
            return .body
        }
    }
    static let threshColor = Color.blue
    static let lightColor = Color.green
    static let commonColor = Color.yellow
    static let strongColor = Color.orange
    static let heavyColor = Color.red

    var body: some View {
        let showDoseView = threshOrLightMin != nil
        || lightMaxOrCommonMin != nil
        || commonMaxOrStrongMin != nil
        || strongMaxOrHeavy != nil
        if showDoseView {
            HStack(alignment: .top, spacing: 0) {
                if let threshOrLightMin = threshOrLightMin {
                    Spacer(minLength: 0)
                    VStack {
                        Text(threshOrLightMin)
                            .foregroundLinearGradient(colors: [Self.threshColor, Self.lightColor])
                            .font(doseFont)
                        Text("thresh ")
                            .foregroundColor(Self.threshColor)
                            .font(.footnote)
                    }
                    Spacer(minLength: 0)
                }
                if threshOrLightMin != nil || lightMaxOrCommonMin != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("light")
                            .font(.footnote)
                    }
                    .foregroundColor(Self.lightColor)
                    Spacer(minLength: 0)
                }
                if let lightMaxOrCommonMin = lightMaxOrCommonMin {
                    Spacer(minLength: 0)
                    Text(lightMaxOrCommonMin)
                        .foregroundLinearGradient(colors: [Self.lightColor, Self.commonColor])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if lightMaxOrCommonMin != nil || commonMaxOrStrongMin != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("common")
                            .font(.footnote)
                    }
                    .foregroundColor(Self.commonColor)
                    Spacer(minLength: 0)
                }
                if let commonMaxOrStrongMin = commonMaxOrStrongMin {
                    Spacer(minLength: 0)
                    Text(commonMaxOrStrongMin)
                        .foregroundLinearGradient(colors: [Self.commonColor, Self.strongColor])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if commonMaxOrStrongMin != nil || strongMaxOrHeavy != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("strong")
                            .font(.footnote)
                    }
                    .foregroundColor(Self.strongColor)
                    Spacer(minLength: 0)
                }
                if let strongMaxOrHeavy = strongMaxOrHeavy {
                    Spacer(minLength: 0)
                    Text(strongMaxOrHeavy)
                        .foregroundLinearGradient(colors: [Self.strongColor, Self.heavyColor])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if strongMaxOrHeavy != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("heavy")
                            .font(.footnote)
                    }
                    .foregroundColor(Self.heavyColor)
                    .font(doseFont)
                    Spacer(minLength: 0)
                }
                if let units = roaDose?.units {
                    Spacer(minLength: 0)
                    Text(units)
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
            }
        } else {
            EmptyView()
        }
    }
}

struct DoseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                List {
                    let dose = PreviewHelper.shared.getSubstance(with: "Melatonin")!.roasUnwrapped.first!.dose!
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

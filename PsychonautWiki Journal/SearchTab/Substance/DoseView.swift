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
    private let threshColor = Color.blue
    private let lightColor = Color.green
    private let commonColor = Color.yellow
    private let strongColor = Color.orange
    private let heavyColor = Color.red

    var body: some View {
        let showDoseView = threshOrLightMin != nil
        || lightMaxOrCommonMin != nil
        || commonMaxOrStrongMin != nil
        || strongMaxOrHeavy != nil
        if showDoseView {
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                Group {
                    if let threshOrLightMin = threshOrLightMin {
                        VStack {
                            Text(threshOrLightMin)
                                .foregroundLinearGradient(colors: [threshColor, lightColor])
                                .font(doseFont)
                            Text("thresh ")
                                .foregroundColor(threshColor)
                                .font(.footnote)
                        }
                    }
                    if threshOrLightMin != nil || lightMaxOrCommonMin != nil {
                        VStack {
                            Text("-")
                                .font(doseFont)
                            Text("light")
                                .font(.footnote)
                        }
                        .foregroundColor(lightColor)
                    }
                    if let lightMaxOrCommonMin = lightMaxOrCommonMin {
                        Text(lightMaxOrCommonMin)
                            .foregroundLinearGradient(colors: [lightColor, commonColor])
                            .font(doseFont)
                    }
                    if lightMaxOrCommonMin != nil || commonMaxOrStrongMin != nil {
                        VStack {
                            Text("-")
                                .font(doseFont)
                            Text("common")
                                .font(.footnote)
                        }
                        .foregroundColor(commonColor)
                    }
                    if let commonMaxOrStrongMin = commonMaxOrStrongMin {
                        Text(commonMaxOrStrongMin)
                            .foregroundLinearGradient(colors: [commonColor, strongColor])
                            .font(doseFont)
                    }
                    if commonMaxOrStrongMin != nil || strongMaxOrHeavy != nil {
                        VStack {
                            Text("-")
                                .font(doseFont)
                            Text("strong")
                                .font(.footnote)
                        }
                        .foregroundColor(strongColor)
                    }
                    if let strongMaxOrHeavy = strongMaxOrHeavy {
                        Text(strongMaxOrHeavy)
                            .foregroundLinearGradient(colors: [strongColor, heavyColor])
                            .font(doseFont)
                    }
                    if strongMaxOrHeavy != nil {
                        VStack {
                            Text("-")
                                .font(doseFont)
                            Text("heavy")
                                .font(.footnote)
                        }
                        .foregroundColor(heavyColor)
                        .font(doseFont)
                    }
                    Text(roaDose?.units ?? "")
                        .font(doseFont)
                }
                Spacer()
            }.listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
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

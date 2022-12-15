import SwiftUI

struct DoseRow: View {

    let roaDose: RoaDose?
    var doseFont: Font {
        if let lightMaxOrCommonMinUnwrap = roaDose?.lightMaxOrCommonMin,
           lightMaxOrCommonMinUnwrap.formatted().count >= 4 {
            return .footnote
        } else if let commonMaxOrStrongMinUnwrap = roaDose?.commonMaxOrStrongMin,
                  commonMaxOrStrongMinUnwrap.formatted().count >= 4 {
            return .footnote
        } else {
            return .body
        }
    }

    var body: some View {
        let showDoseRow = roaDose?.threshOrLightMin != nil
        || roaDose?.lightMaxOrCommonMin != nil
        || roaDose?.commonMaxOrStrongMin != nil
        || roaDose?.strongMaxOrHeavy != nil
        if showDoseRow && roaDose?.units != nil {
            HStack(alignment: .top, spacing: 0) {
                if let threshOrLightMin = roaDose?.threshOrLightMin {
                    Spacer(minLength: 0)
                    VStack {
                        Text(threshOrLightMin.formatted())
                            .foregroundLinearGradient(colors: [DoseRangeType.thresh.color, DoseRangeType.light.color])
                            .font(doseFont)
                        Text("thresh ")
                            .maybeCondensed()
                            .lineLimit(1)
                            .foregroundColor(DoseRangeType.thresh.color)
                            .font(.footnote)

                    }
                    Spacer(minLength: 0)
                }
                if roaDose?.threshOrLightMin != nil || roaDose?.lightMaxOrCommonMin != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("light")
                            .maybeCondensed()
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    .foregroundColor(DoseRangeType.light.color)
                    Spacer(minLength: 0)
                }
                if let lightMaxOrCommonMin = roaDose?.lightMaxOrCommonMin {
                    Spacer(minLength: 0)
                    Text(lightMaxOrCommonMin.formatted())
                        .foregroundLinearGradient(colors: [DoseRangeType.light.color, DoseRangeType.common.color])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if roaDose?.lightMaxOrCommonMin != nil || roaDose?.commonMaxOrStrongMin != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("common")
                            .maybeCondensed()
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    .foregroundColor(DoseRangeType.common.color)
                    Spacer(minLength: 0)
                }
                if let commonMaxOrStrongMin = roaDose?.commonMaxOrStrongMin {
                    Spacer(minLength: 0)
                    Text(commonMaxOrStrongMin.formatted())
                        .foregroundLinearGradient(colors: [DoseRangeType.common.color, DoseRangeType.strong.color])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if roaDose?.commonMaxOrStrongMin != nil || roaDose?.strongMaxOrHeavy != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("strong")
                            .maybeCondensed()
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    .foregroundColor(DoseRangeType.strong.color)
                    Spacer(minLength: 0)
                }
                if let strongMaxOrHeavy = roaDose?.strongMaxOrHeavy {
                    Spacer(minLength: 0)
                    Text(strongMaxOrHeavy.formatted())
                        .foregroundLinearGradient(colors: [DoseRangeType.strong.color, DoseRangeType.heavy.color])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if roaDose?.strongMaxOrHeavy != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("heavy")
                            .maybeCondensed()
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    .foregroundColor(DoseRangeType.heavy.color)
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

extension View {
    @ViewBuilder
    func maybeCondensed() -> some View {
        if #available(iOS 16, *) {
            self
                .fontWidth(.condensed)
        } else {
            self
        }
    }
}

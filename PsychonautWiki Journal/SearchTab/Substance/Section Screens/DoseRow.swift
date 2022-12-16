import SwiftUI

struct DoseRow: View {

    let roaDose: RoaDose?
    var doseFont: Font {
        if let commonMinUnwrap = roaDose?.commonMin,
           commonMinUnwrap.formatted().count >= 4 {
            return .footnote
        } else if let strongMinUnwrap = roaDose?.strongMin,
                  strongMinUnwrap.formatted().count >= 4 {
            return .footnote
        } else {
            return .body
        }
    }

    var body: some View {
        let showDoseRow = roaDose?.lightMin != nil
        || roaDose?.commonMin != nil
        || roaDose?.strongMin != nil
        || roaDose?.heavyMin != nil
        if showDoseRow && roaDose?.units != nil {
            HStack(alignment: .top, spacing: 0) {
                if let lightMin = roaDose?.lightMin {
                    Spacer(minLength: 0)
                    VStack {
                        Text(lightMin.formatted())
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
                if roaDose?.lightMin != nil || roaDose?.commonMin != nil {
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
                if let commonMin = roaDose?.commonMin {
                    Spacer(minLength: 0)
                    Text(commonMin.formatted())
                        .foregroundLinearGradient(colors: [DoseRangeType.light.color, DoseRangeType.common.color])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if roaDose?.commonMin != nil || roaDose?.strongMin != nil {
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
                if let strongMin = roaDose?.strongMin {
                    Spacer(minLength: 0)
                    Text(strongMin.formatted())
                        .foregroundLinearGradient(colors: [DoseRangeType.common.color, DoseRangeType.strong.color])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if roaDose?.strongMin != nil || roaDose?.heavyMin != nil {
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
                if let heavyMin = roaDose?.heavyMin {
                    Spacer(minLength: 0)
                    Text(heavyMin.formatted())
                        .foregroundLinearGradient(colors: [DoseRangeType.strong.color, DoseRangeType.heavy.color])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if roaDose?.heavyMin != nil {
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

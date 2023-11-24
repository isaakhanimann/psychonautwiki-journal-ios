// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import Foundation

func getMinInfoForEachLine(from ingestions: [Ingestion]) -> [IngestionMinInfoForLine] {
    ingestions.map { ingestion in
        IngestionMinInfoForLine(
            substanceName: ingestion.substanceNameUnwrapped,
            color: ingestion.substanceColor,
            route: ingestion.administrationRouteUnwrapped,
            dose: ingestion.doseUnwrapped,
            ingestionTime: ingestion.timeUnwrapped,
            onsetDelayInHours: ingestion.stomachFullnessUnwrapped?.onsetDelayForOralInHours ?? 0)
    }
}

struct SubstanceIngestionGroupStep1 {
    let substanceName: String
    let color: SubstanceColor
    let routeMinInfos: [RouteMinInfoStep1]
}

struct RouteMinInfoStep1 {
    let route: AdministrationRoute
    let ingestions: [IngestionStep1]
}

struct IngestionStep1 {
    let dose: Double?
    let ingestionTime: Date
    let onsetDelayInHours: Double
}

// step 1
// group substances and routes together
// return value is ready to be sent to live activity
func getSubstanceIngestionGroups(ingestions: [Ingestion]) -> [SubstanceIngestionGroupStep1] {
    let minInfoForEachLine = getMinInfoForEachLine(from: ingestions)
    let substanceDict = Dictionary(grouping: minInfoForEachLine) { minInfo in
        minInfo.substanceName
    }
    let substanceIngestionGroups: [SubstanceIngestionGroupStep1] = substanceDict.compactMap { (substanceName: String, ingestionMinInfoForLines: [IngestionMinInfoForLine]) in
        guard let color = ingestionMinInfoForLines.first?.color else {return nil}
        let routeDict = Dictionary(grouping: ingestionMinInfoForLines) { value in
            value.route
        }
        let routeMinInfos = routeDict.map { (route: AdministrationRoute, values: [IngestionMinInfoForLine]) in
            let ingestions = values.map { ingestionMinInfo in
                IngestionStep1(
                    dose: ingestionMinInfo.dose,
                    ingestionTime: ingestionMinInfo.ingestionTime,
                    onsetDelayInHours: ingestionMinInfo.onsetDelayInHours
                )
            }
            return RouteMinInfoStep1(
                route: route,
                ingestions: ingestions)

        }
        return SubstanceIngestionGroupStep1(
            substanceName: substanceName,
            color: color,
            routeMinInfos: routeMinInfos)
    }
    return substanceIngestionGroups
}



struct EnhancedSubstanceGroup {
    let color: SubstanceColor
    let enhancedRoaGroups: [EnhancedRoaGroup]
}

struct EnhancedRoaGroup {
    let roaDuration: RoaDuration?
    let ingestions: [EnhancedMinIngestion]
}

struct EnhancedMinIngestion {
    let relativeDose: RelativeDoseOption
    let horizontalWeight: Double
    let ingestionTime: Date
    let onsetDelayInHours: Double
}

enum RelativeDoseOption: Equatable, AdditiveArithmetic {
    case unknownDose
    case strengthUnknown(originalDose: Double)
    case strengthKnown(originalDose: Double, strength: Double)
    case zero

    static func + (lhs: RelativeDoseOption, rhs: RelativeDoseOption) -> RelativeDoseOption {
        switch lhs {
        case .zero:
            return rhs
        case .unknownDose:
            return .unknownDose
        case .strengthUnknown(let originalDoseLeft):
            switch rhs {
            case .zero:
                return lhs
            case .unknownDose:
                return .unknownDose
            case .strengthUnknown(let originalDoseRight):
                return .strengthUnknown(originalDose: originalDoseLeft + originalDoseRight)
            case .strengthKnown(let originalDoseRight, let strengthRight):
                let ratio = strengthRight/originalDoseRight
                let strengthLeft = ratio * originalDoseLeft
                let newStrength = strengthRight + strengthLeft
                return .strengthKnown(
                    originalDose: originalDoseLeft + originalDoseRight,
                    strength: newStrength)
            }
        case .strengthKnown(let originalDoseLeft, let strengthLeft):
            switch rhs {
            case .zero:
                return lhs
            case .unknownDose:
                return .unknownDose
            case .strengthUnknown(let originalDoseRight):
                let ratio = strengthLeft/originalDoseLeft
                let strengthRight = ratio * originalDoseRight
                let newStrength = strengthRight + strengthLeft
                return .strengthKnown(
                    originalDose: originalDoseLeft + originalDoseRight,
                    strength: newStrength)
            case .strengthKnown(let originalDoseRight, let strengthRight):
                return .strengthKnown(
                    originalDose: originalDoseLeft + originalDoseRight,
                    strength: strengthLeft + strengthRight)
            }
        }
    }

    static func - (lhs: RelativeDoseOption, rhs: RelativeDoseOption) -> RelativeDoseOption {
        switch lhs {
        case .zero:
            return rhs
        case .unknownDose:
            return .unknownDose
        case .strengthUnknown(let originalDoseLeft):
            switch rhs {
            case .zero:
                return lhs
            case .unknownDose:
                return .unknownDose
            case .strengthUnknown(let originalDoseRight):
                return .strengthUnknown(originalDose: originalDoseLeft - originalDoseRight)
            case .strengthKnown(let originalDoseRight, let strengthRight):
                let ratio = strengthRight/originalDoseRight
                let strengthLeft = ratio * originalDoseLeft
                let newStrength =  strengthLeft - strengthRight
                return .strengthKnown(
                    originalDose: originalDoseLeft - originalDoseRight,
                    strength: newStrength)
            }
        case .strengthKnown(let originalDoseLeft, let strengthLeft):
            switch rhs {
            case .zero:
                return lhs
            case .unknownDose:
                return .unknownDose
            case .strengthUnknown(let originalDoseRight):
                let ratio = strengthLeft/originalDoseLeft
                let strengthRight = ratio * originalDoseRight
                let newStrength = strengthLeft - strengthRight
                return .strengthKnown(
                    originalDose: originalDoseLeft - originalDoseRight,
                    strength: newStrength)
            case .strengthKnown(let originalDoseRight, let strengthRight):
                return .strengthKnown(
                    originalDose: originalDoseLeft - originalDoseRight,
                    strength: strengthLeft - strengthRight)
            }
        }
    }

    func divide(by divisor: Double) -> RelativeDoseOption {
        switch self {
        case .zero:
            return .zero
        case .unknownDose:
            return .unknownDose
        case .strengthUnknown(let originalDose):
            return .strengthUnknown(originalDose: originalDose/divisor)
        case .strengthKnown(let originalDose, let strength):
            return .strengthKnown(originalDose: originalDose/divisor, strength: strength/divisor)
        }
    }

    func multiply(by multiplier: Double) -> RelativeDoseOption {
        switch self {
        case .zero:
            return .zero
        case .unknownDose:
            return .unknownDose
        case .strengthUnknown(let originalDose):
            return .strengthUnknown(originalDose: originalDose*multiplier)
        case .strengthKnown(let originalDose, let strength):
            return .strengthKnown(originalDose: originalDose*multiplier, strength: strength*multiplier)
        }
    }
}

// step 2
// get info of substances and classify doses relatively
func getEnhancedSubstanceGroup(substanceIngestionGroups: [SubstanceIngestionGroupStep1]) -> [EnhancedSubstanceGroup] {
    substanceIngestionGroups.map { substanceIngestionGroup in
        let substance = SubstanceRepo.shared.getSubstance(name: substanceIngestionGroup.substanceName)
        let enhancedRoaGroups = substanceIngestionGroup.routeMinInfos.map { routeMinInfo in
            let roaDuration = substance?.getDuration(for: routeMinInfo.route)
            let roaDose = substance?.getDose(for: routeMinInfo.route)
            let allRoas = substanceIngestionGroup.routeMinInfos.map({$0.route})
            let enhancedDoses = routeMinInfo.ingestions.map { ingestion in
                var relativeDose = RelativeDoseOption.unknownDose
                if let dose = ingestion.dose {
                    if let strength = roaDose?.getValueRelativeToAverageCommonDose(for: dose) {
                        relativeDose = .strengthKnown(originalDose: dose,strength: strength)
                    } else {
                        relativeDose = .strengthUnknown(originalDose: dose)
                    }
                }
                var horizontalWeight = 0.5
                if let dose = ingestion.dose, let roaDose {
                    let doseType = roaDose.getRangeType(for: dose, with: roaDose.units)
                    switch doseType {
                    case .thresh:
                        horizontalWeight = 0
                    case .light:
                        horizontalWeight = 0.25
                    case .common:
                        horizontalWeight = 0.5
                    case .strong:
                        horizontalWeight = 0.75
                    case .heavy:
                        horizontalWeight = 1
                    case .none:
                        horizontalWeight = 0.5
                    }
                }
                return EnhancedMinIngestion(
                    relativeDose: relativeDose,
                    horizontalWeight: horizontalWeight,
                    ingestionTime: ingestion.ingestionTime,
                    onsetDelayInHours: ingestion.onsetDelayInHours
                )
            }
            return EnhancedRoaGroup(
                roaDuration: roaDuration,
                ingestions: enhancedDoses)
        }
        return EnhancedSubstanceGroup(
            color: substanceIngestionGroup.color,
            enhancedRoaGroups: enhancedRoaGroups)
    }
}

// each bin can be drawn at once
struct FinalSubstanceGroup {
    let color: SubstanceColor
    let binFull: [BinElement<RoaDurationFull>]
    let binOnsetComeupPeakTotal: [BinElement<RoaDurationOnsetComeupPeakTotal>]
    let binOnsetComeupPeak: [BinElement<RoaDurationOnsetComeupPeak>]
    let binOnsetComeupTotal: [BinElement<RoaDurationOnsetComeupTotal>]
    let binOnsetComeup: [BinElement<RoaDurationOnsetComeup>]
    let binOnsetTotal: [BinElement<RoaDurationOnsetTotal>]
    let binOnset: [BinElement<RoaDurationOnset>]
    let binTotal: [BinElement<RoaDurationTotal>]
    let binNoInfo: [EnhancedMinIngestion]
}


struct BinElement<RoaDurationNonOptional: NonOptional> {
    let nonOptional: RoaDurationNonOptional
    let ingestions: [EnhancedMinIngestion]
}

// step 3
// based on each RoaDuration put elements into bins
func getFinalSubstanceGroup(enhancedSubstanceGroups: [EnhancedSubstanceGroup]) -> [FinalSubstanceGroup] {
    enhancedSubstanceGroups.map { enhancedSubstanceGroup in
        var binFull: [BinElement<RoaDurationFull>] = []
        var binOnsetComeupPeakTotal: [BinElement<RoaDurationOnsetComeupPeakTotal>] = []
        var binOnsetComeupPeak: [BinElement<RoaDurationOnsetComeupPeak>] = []
        var binOnsetComeupTotal: [BinElement<RoaDurationOnsetComeupTotal>] = []
        var binOnsetComeup: [BinElement<RoaDurationOnsetComeup>] = []
        var binOnsetTotal: [BinElement<RoaDurationOnsetTotal>] = []
        var binOnset: [BinElement<RoaDurationOnset>] = []
        var binTotal: [BinElement<RoaDurationTotal>] = []
        var binNoInfo: [EnhancedMinIngestion]

        for enhancedRoaGroup in enhancedSubstanceGroup.enhancedRoaGroups {
            let nonOptionalRoa = enhancedRoaGroup.roaDuration?.toNonOptional()
            let ingestions = enhancedRoaGroup.ingestions
            if let full = nonOptionalRoa as? RoaDurationFull {
                binFull.append(BinElement(
                    nonOptional: full,
                    ingestions: ingestions))
            } else if let onsetComeupPeakTotal = nonOptionalRoa as? RoaDurationOnsetComeupPeakTotal {
                binOnsetComeupPeakTotal.append(BinElement(
                    nonOptional: onsetComeupPeakTotal,
                    ingestions: ingestions))
            } else if let onsetComeupPeak = nonOptionalRoa as? RoaDurationOnsetComeupPeak {
                binOnsetComeupPeak.append(BinElement(
                    nonOptional: onsetComeupPeak,
                    ingestions: ingestions))
            } else if let onsetComeupTotal = nonOptionalRoa as? RoaDurationOnsetComeupTotal {
                binOnsetComeupTotal.append(BinElement(
                    nonOptional: onsetComeupTotal,
                    ingestions: ingestions))
            } else if let onsetComeup = nonOptionalRoa as? RoaDurationOnsetComeup {
                binOnsetComeup.append(BinElement(
                    nonOptional: onsetComeup,
                    ingestions: ingestions))
            } else if let onsetTotal = nonOptionalRoa as? RoaDurationOnsetTotal {
                binOnsetTotal.append(BinElement(
                    nonOptional: onsetTotal,
                    ingestions: ingestions))
            } else if let onset = nonOptionalRoa as? RoaDurationOnset {
                binOnset.append(BinElement(
                    nonOptional: onset,
                    ingestions: ingestions))
            } else if let total = nonOptionalRoa as? RoaDurationTotal {
                binTotal.append(BinElement(
                    nonOptional: total,
                    ingestions: ingestions))
            } else {
                binNoInfo.append(contentsOf: ingestions)
            }
        }
        return FinalSubstanceGroup(
            color: enhancedSubstanceGroup.color,
            binFull: binFull,
            binOnsetComeupPeakTotal: binOnsetComeupPeakTotal,
            binOnsetComeupPeak: binOnsetComeupPeak,
            binOnsetComeupTotal: binOnsetComeupTotal,
            binOnsetComeup: binOnsetComeup,
            binOnsetTotal: binOnsetTotal,
            binOnset: binOnset,
            binTotal: binTotal,
            binNoInfo: binNoInfo)
    }
}

struct BinElementNormalized<RoaDurationNonOptional: NonOptional> {
    let nonOptional: RoaDurationNonOptional
    let ingestions: [EnhancedMinIngestion]
}


struct FullTimeDosePoint {
    let time: Date
    let relativeDose: RelativeDoseOption
    let isIngestionPoint: Bool
}

struct LinePoint {
    let x: Date
    let y: RelativeDoseOption
}

struct LineSegmentForCumulative {

    let start: LinePoint
    let end: LinePoint

    func isInside(x: Date) -> Bool {
        return start.x <= x && x < end.x
    }

    func height(at x: Date) -> RelativeDoseOption {
        let distanceFromStart = x.timeIntervalSinceReferenceDate-start.x.timeIntervalSinceReferenceDate
        let heightDiff = end.y-start.y
        let widthDiff = end.x.timeIntervalSinceReferenceDate-start.x.timeIntervalSinceReferenceDate
        assert(widthDiff>0)
        guard widthDiff > 0 else {return .zero}
        return start.y + heightDiff.multiply(by: distanceFromStart).divide(by: widthDiff)
    }
}

// step 4
// put the lines on top of each other
func cumulateBinFull(binFull: [BinElement<RoaDurationFull>]) -> [FullTimeDosePoint] {
    // map to lines
    var lines: [LineSegmentForCumulative] = []
    for elem in binFull {
        let full = elem.nonOptional
        for ingestion in elem.ingestions {
            let ingestionTime = ingestion.ingestionTime
            let onsetDelayInHours = ingestion.onsetDelayInHours
            let comeupStartX = ingestionTime.addingTimeInterval(onsetDelayInHours*60*60).addingTimeInterval(full.onset.interpolateLinearly(at: 0.5))
            let comeupStartPoint = LinePoint(x: comeupStartX, y: .zero)
            let peakStartX = comeupStartX.addingTimeInterval(full.comeup.interpolateLinearly(at: 0.5))
            let peakStartPoint = LinePoint(x: peakStartX, y: ingestion.relativeDose)
            lines.append(LineSegmentForCumulative(start: comeupStartPoint, end: peakStartPoint))
            let offsetStartX = peakStartX.addingTimeInterval(full.peak.interpolateLinearly(at: ingestion.horizontalWeight))
            let offsetStartPoint = LinePoint(
                x: offsetStartX,
                y: ingestion.relativeDose)
            lines.append(LineSegmentForCumulative(start: peakStartPoint, end: offsetStartPoint))
            let offsetEndX = offsetStartX.addingTimeInterval(full.offset.interpolateLinearly(at: ingestion.horizontalWeight))
            let offsetEndPoint = LinePoint(x: offsetEndX, y: .zero)
            lines.append(LineSegmentForCumulative(start: offsetStartPoint, end: offsetEndPoint))
        }
    }
    // create points from adding up values at lines
    var points: [FullTimeDosePoint] = []
    for elem in binFull {
        for ingestion in elem.ingestions {
            let ingestionTime = ingestion.ingestionTime
            var sum = RelativeDoseOption.zero
            for line in lines {
                if line.isInside(x: ingestionTime) {
                    sum += line.height(at: ingestionTime)
                }
            }
            let point = FullTimeDosePoint(
                time: ingestionTime,
                relativeDose: sum,
                isIngestionPoint: true)
            points.append(point)
        }
    }
    var xs: [Date] = lines.flatMap({[$0.start.x, $0.end.x]}).uniqued()
    for x in xs {
        var sum = RelativeDoseOption.zero
        for line in lines {
            if line.isInside(x: x) {
                sum += line.height(at: x)
            }
        }
        let point = FullTimeDosePoint(
            time: x,
            relativeDose: sum,
            isIngestionPoint: false)
        points.append(point)
    }
    let sortedPoints = points.sorted { lhs, rhs in
        lhs.time < rhs.time
    }
    return sortedPoints
}


// step 5
// normalize all the y values between 0 and 1 based on user setting






func getEverythingForEachLine(from ingestions: [Ingestion]) -> [EverythingForOneLine] {
    let dosePairs: [(String, Double)] = ingestions.compactMap({ ing in
        guard let dose = ing.doseUnwrapped else {return nil}
        return (ing.substanceNameUnwrapped, dose)
    })
    let maxDoses = Dictionary(dosePairs) { dose1, dose2 in
        max(dose1, dose2)
    }
    return ingestions.map { ingestion in
        let substanceName = ingestion.substanceNameUnwrapped
        let substance = SubstanceRepo.shared.getSubstance(name: substanceName)
        let roaDuration = substance?.getDuration(for: ingestion.administrationRouteUnwrapped)
        let roaDose = substance?.getDose(for: ingestion.administrationRouteUnwrapped)
        var horizontalWeight = 0.5
        if let dose = ingestion.doseUnwrapped, let units = ingestion.units, let roaDose {
            let doseType = roaDose.getRangeType(for: dose, with: units)
            switch doseType {
            case .thresh:
                horizontalWeight = 0
            case .light:
                horizontalWeight = 0.25
            case .common:
                horizontalWeight = 0.5
            case .strong:
                horizontalWeight = 0.75
            case .heavy:
                horizontalWeight = 1
            case .none:
                horizontalWeight = 0.5
            }
        }
        var verticalWeight = 1.0
        if let dose = ingestion.doseUnwrapped, let max = maxDoses[substanceName] {
            verticalWeight = dose/max
        }
        return EverythingForOneLine(
            substanceName: ingestion.substanceNameUnwrapped,
            route: ingestion.administrationRouteUnwrapped,
            roaDuration: roaDuration,
            onsetDelayInHours: ingestion.stomachFullnessUnwrapped?.onsetDelayForOralInHours ?? 0,
            startTime: ingestion.timeUnwrapped,
            horizontalWeight: horizontalWeight,
            verticalWeight: verticalWeight,
            color: ingestion.substanceColor
        )
    }
}

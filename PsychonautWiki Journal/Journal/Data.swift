//
//  Data.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 30.12.22.
//

import SwiftUI

func date(year: Int, month: Int, day: Int = 1) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}

/// Data for the top style charts.
struct IngestionData {
    /// Sales by pancake style for the last 30 days, sorted by amount.
    static let last30Days = [
        (name: "Cachapa", sales: 916),
        (name: "Injera", sales: 850),
        (name: "Crêpe", sales: 802),
        (name: "Jian Bing", sales: 753),
        (name: "Dosa", sales: 654),
        (name: "American", sales: 618)
    ]

    /// Sales by pancake style for the last 12 months, sorted by amount.
    static let last12Months = [
        (name: "Cachapa", sales: 9631),
        (name: "Crêpe", sales: 7959),
        (name: "Injera", sales: 7891),
        (name: "Jian Bing", sales: 7506),
        (name: "American", sales: 6777),
        (name: "Dosa", sales: 6325)
    ]
}

struct ExperienceData {

    struct SubstanceExperienceCountForDay {
        let day: Date
        let substanceName: String
        let experienceCount: Double
    }

    static let substanceColors: KeyValuePairs<String, Color> = [
        "MDMA": Color.pink,
        "Cannabis": .green,
        "Cocaine": .blue,
        "Amphetamine": .cyan,
        "LSD": .purple
    ]

    static let last30Days: [SubstanceExperienceCountForDay] = [
        .init(day: date(year: 2022, month: 5, day: 8), substanceName: "MDMA", experienceCount: 0.5),
        .init(day: date(year: 2022, month: 5, day: 8), substanceName: "Cannabis", experienceCount: 0.5),
        .init(day: date(year: 2022, month: 5, day: 9), substanceName: "Cannabis", experienceCount: 1),
        .init(day: date(year: 2022, month: 5, day: 10), substanceName: "Cannabis", experienceCount: 1),
        .init(day: date(year: 2022, month: 5, day: 13), substanceName: "Cocaine", experienceCount: 1.0/3),
        .init(day: date(year: 2022, month: 5, day: 13), substanceName: "Amphetamine", experienceCount: 1.0/3),
        .init(day: date(year: 2022, month: 5, day: 13), substanceName: "LSD", experienceCount: 1.0/3),
        .init(day: date(year: 2022, month: 5, day: 14), substanceName: "Cannabis", experienceCount: 1),
        .init(day: date(year: 2022, month: 5, day: 15), substanceName: "MDMA", experienceCount: 1),
        .init(day: date(year: 2022, month: 5, day: 25), substanceName: "Cocaine", experienceCount: 0.5),
        .init(day: date(year: 2022, month: 5, day: 25), substanceName: "MDMA", experienceCount: 0.5),
        .init(day: date(year: 2022, month: 5, day: 27), substanceName: "Cannabis", experienceCount: 0.25),
        .init(day: date(year: 2022, month: 5, day: 27), substanceName: "Amphetamine", experienceCount: 0.25),
        .init(day: date(year: 2022, month: 5, day: 27), substanceName: "MDMA", experienceCount: 0.25),
        .init(day: date(year: 2022, month: 5, day: 27), substanceName: "Cocaine", experienceCount: 0.25)
    ]

    /// Total sales for the last 30 days.
    static var last30DaysTotal: Double {
        last30Days.map { $0.experienceCount }.reduce(0, +)
    }

    static var last30DaysAverage: Double {
        last30DaysTotal / Double(last30Days.count)
    }

    struct SubstanceExperienceCountForMonth {
        let month: Date
        let substanceName: String
        let experienceCount: Double
    }

    /// Sales by month for the last 12 months.
    static let last12Months: [SubstanceExperienceCountForMonth] = [
        .init(month: date(year: 2021, month: 7), substanceName: "MDMA", experienceCount: 1),
        .init(month: date(year: 2021, month: 7), substanceName: "Cocaine", experienceCount: 2),
        .init(month: date(year: 2021, month: 7), substanceName: "Cannabis", experienceCount: 10),
        .init(month: date(year: 2021, month: 8), substanceName: "Cocaine", experienceCount: 1),
        .init(month: date(year: 2021, month: 8), substanceName: "Cannabis", experienceCount: 5),
        .init(month: date(year: 2021, month: 9), substanceName: "Amphetamine", experienceCount: 2),
        .init(month: date(year: 2021, month: 9), substanceName: "Cannabis", experienceCount: 3),
        .init(month: date(year: 2022, month: 1), substanceName: "MDMA", experienceCount: 1),
        .init(month: date(year: 2022, month: 1), substanceName: "Cannabis", experienceCount: 5),
        .init(month: date(year: 2022, month: 3), substanceName: "Amphetamine", experienceCount: 3)
    ]

    /// Total sales for the last 12 months.
    static var last12MonthsTotal: Double {
        last12Months.map { $0.experienceCount }.reduce(0, +)
    }
}

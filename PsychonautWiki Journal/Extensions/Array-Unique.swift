//
//  Array-Unique.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 09.01.23.
//

import Foundation

extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}

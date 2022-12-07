//
//  Interactions.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 06.12.22.
//

import Foundation

struct Interactions: Decodable {
    let uncertain: [String]
    let unsafe: [String]
    let dangerous: [String]
}

//
//  SubstanceFile.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 06.12.22.
//

import Foundation

struct SubstanceFile: Decodable {
    let categories: [Category]
    let substances: [Substance]
}

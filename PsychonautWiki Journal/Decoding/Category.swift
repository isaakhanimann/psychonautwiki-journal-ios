//
//  Category.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 06.12.22.
//

import Foundation

struct Category: Decodable {
    let name: String
    let description: String
    let url: URL?
}

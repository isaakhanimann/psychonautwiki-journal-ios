//
//  ExperienceLocation-CoreDataHelpers.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 09.01.23.
//

import Foundation

extension ExperienceLocation {
    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var latitudeUnwrapped: Double? {
        if latitude == 0 {
            return nil
        } else {
            return latitude
        }
    }

    var longitudeUnwrapped: Double? {
        if longitude == 0 {
            return nil
        } else {
            return longitude
        }
    }

}

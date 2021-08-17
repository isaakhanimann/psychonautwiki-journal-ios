//
//  PsychonautWiki_JournalApp.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 17.08.21.
//

import SwiftUI

@main
struct PsychonautWiki_JournalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

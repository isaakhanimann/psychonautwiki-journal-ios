//
//  IngestionNote-ViewModel.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 07.01.23.
//

import Foundation

extension IngestionNoteScreen {

    @MainActor
    class ViewModel: ObservableObject {

        @Published var suggestedNotesInOrder = [String]()

        init() {
            let ingestionFetchRequest = Ingestion.fetchRequest()
            ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
            ingestionFetchRequest.predicate = NSPredicate(format: "note.length > 0")
            ingestionFetchRequest.fetchLimit = 15
            let sortedIngestions = (try? PersistenceController.shared.viewContext.fetch(ingestionFetchRequest)) ?? []
            suggestedNotesInOrder = sortedIngestions.map { ing in
                ing.noteUnwrapped
            }.uniqued()
        }
    }
}

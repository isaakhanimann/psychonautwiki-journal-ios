//
//  Settings-ViewModel.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 28.12.22.
//

import Foundation

extension SettingsScreen {
    @MainActor
    class ViewModel: ObservableObject {

        @Published var isImporting = false
        @Published var isExporting = false
        @Published var journalFile = JournalFile()

        func exportData() {
            
        }

        func importData() {

        }

    }
}

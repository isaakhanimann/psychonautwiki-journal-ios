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

        @Published var isExporting = false
        @Published var journalFile = JournalFile()

        func exportData() {
            // Todo: prepare journalFile for export
            isExporting = true
        }

        func importData(data: Data) {
            // Todo: decode journal file from this data and save in core data
        }

    }
}

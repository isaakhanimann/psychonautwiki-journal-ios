//
//  JournalFile.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 28.12.22.
//

import SwiftUI
import UniformTypeIdentifiers


struct JournalFile: FileDocument, Codable {
    static var readableContentTypes = [UTType.json]
    static var writableContentTypes = [UTType.json]
    var substances: [String]

    init(substances: [String] = []) {
        self.substances = substances
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self = try JSONDecoder().decode(Self.self, from: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        return FileWrapper(regularFileWithContents: data)
    }
}



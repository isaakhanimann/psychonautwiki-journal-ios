//
//  SubstanceIngestionScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 02.01.23.
//

import SwiftUI

struct SubstanceIngestionScreen: View {

    @FetchRequest var fetchRequest: FetchedResults<Ingestion>
    let substanceName: String

    init(substanceName: String) {
        self.substanceName = substanceName
        _fetchRequest = FetchRequest<Ingestion>(
            sortDescriptors: [SortDescriptor(\.time, order: .reverse)],
            predicate: NSPredicate(format: "substanceName == %@", substanceName)
        )
    }

    var body: some View {
        List(fetchRequest, id: \.self) { ingestion in
            Text(ingestion.timeUnwrapped, style: .date)
        }.navigationTitle(substanceName)
    }
}

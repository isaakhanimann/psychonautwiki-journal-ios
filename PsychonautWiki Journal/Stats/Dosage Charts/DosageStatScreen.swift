// Copyright (c) 2024. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI

struct DosageStatScreen: View {

    let substanceName: String

    init(substanceName: String) {
        self.substanceName = substanceName
        self.ingestions = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "consumerName=nil OR consumerName=''"),
                NSPredicate(format: "substanceName == %@", substanceName)
            ]))
    }

    private var ingestions: FetchRequest<Ingestion>


    var body: some View {
        List {
            Text("hello")
        }
        .navigationTitle("\(substanceName) Dosage Stat")
        .onChange(of: ingestions.wrappedValue.count, perform: { _ in
            calculateStats()
        })
    }

    @State private var dosageStat: DosageStat?

    private func calculateStats() {
        
    }
}

#Preview {
    DosageStatScreen(substanceName: "MDMA")
}

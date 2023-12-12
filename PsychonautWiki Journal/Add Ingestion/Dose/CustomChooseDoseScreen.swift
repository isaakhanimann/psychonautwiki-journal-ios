// Copyright (c) 2022. Isaak Hanimann.
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

struct CustomChooseDoseScreen: View {

    let substanceName: String
    let units: String
    let administrationRoute: AdministrationRoute
    let dismiss: () -> Void
    @State private var doseText = ""
    @State private var isShowingNext = false
    @State private var dose: Double? = nil
    @State private var isEstimate = false
    @FocusState private var isDoseFieldFocused: Bool

    var body: some View {
        screen.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                nextLink
            }
        }
    }

    private var nextLink: some View {
        NavigationLink(
            destination: FinishIngestionScreen(
                substanceName: substanceName,
                administrationRoute: administrationRoute,
                dose: dose,
                units: units,
                isEstimate: isEstimate,
                dismiss: dismiss
            ),
            isActive: $isShowingNext
        ) {
            NextLabel()
        }
    }

    private var unknownDoseLink: some View {
        Button("Use Unknown Dose") {
            dose = nil
            isShowingNext = true
        }
    }

    private var screen: some View {
        Form {
            Section {
                HStack {
                    TextField("Enter Dose", text: $doseText)
                        .focused($isDoseFieldFocused)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: doseText) { text in
                            dose = getDouble(from: text)
                        }
                    Text(units)
                }
                .font(.title)
                Toggle("Dose is an Estimate", isOn: $isEstimate)
                    .tint(.accentColor)
                unknownDoseLink
            }
        }
        .task {
            isDoseFieldFocused = true
        }
        .optionalScrollDismissesKeyboard()
        .navigationTitle("\(substanceName) Dose")
    }
}

struct CustomChooseDoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CustomChooseDoseScreen(
                substanceName: "Coffee",
                units: "cups",
                administrationRoute: .oral,
                dismiss: {}
            )
        }
    }
}

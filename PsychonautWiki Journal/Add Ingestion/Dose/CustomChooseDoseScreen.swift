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
        Form {
            Section {
                HStack {
                    TextField("Enter Dose", text: $doseText)
                        .focused($isDoseFieldFocused)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: doseText) { newValue in
                            let formatter = NumberFormatter()
                            formatter.locale = Locale.current
                            formatter.numberStyle = .decimal
                            if let doseUnwrapped = formatter.number(from: doseText)?.doubleValue {
                                dose = doseUnwrapped
                            } else {
                                dose = nil
                            }
                        }
                    Text(units)
                }
                .font(.title)
                Toggle("Dose is an Estimate", isOn: $isEstimate)
                    .tint(.accentColor)
                    .padding(.bottom, 5)
            }
        }
        .task {
            isDoseFieldFocused = true
        }
        .optionalScrollDismissesKeyboard()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    hideKeyboard()
                } label: {
                    Label(
                        "Hide Keyboard",
                        systemImage: "keyboard.chevron.compact.down"
                    ).labelStyle(.iconOnly)
                }
                Button {
                    isShowingNext = true
                } label: {
                    Label(
                        "Next",
                        systemImage: "chevron.forward.circle.fill"
                    )
                    .labelStyle(.titleAndIcon)
                    .font(.headline)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Use Unknown Dose") {
                    dose = nil
                    isShowingNext = true
                }
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
                    Label("Next", systemImage: "chevron.forward.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }.disabled(dose==nil)
            }
        }
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

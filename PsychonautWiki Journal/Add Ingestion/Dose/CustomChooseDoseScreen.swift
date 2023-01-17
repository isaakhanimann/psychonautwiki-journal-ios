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
        if #available(iOS 16, *) {
            screen.toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HideKeyboardButton()
                    Button {
                        isShowingNext = true
                    } label: {
                        NextLabel()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    unknownDoseLink
                    nextLink
                }
            }
        } else {
            screen.toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HideKeyboardButton()
                    Button {
                        isShowingNext = true
                    } label: {
                        NextLabel()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    nextLink
                }
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
        }.disabled(dose==nil)
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
            if #unavailable(iOS 16) {
                Section {
                    unknownDoseLink
                }
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

//
//  CustomChooseDoseScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 12.12.22.
//

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

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section {
                    HStack {
                        TextField("Enter Dose", text: $doseText)
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
                    Toggle("Dose is an Estimate", isOn: $isEstimate).tint(.accentColor).padding(.bottom, 5)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    hideKeyboard()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    dose = nil
                    isShowingNext = true
                } label: {
                    Label("Use Unknown Dose", systemImage: "exclamationmark.triangle").labelStyle(.titleAndIcon)
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

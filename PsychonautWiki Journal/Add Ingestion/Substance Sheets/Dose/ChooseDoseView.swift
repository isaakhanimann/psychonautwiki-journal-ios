import SwiftUI

struct ChooseDoseView: View {

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dismiss: () -> Void
    @StateObject private var viewModel = ViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    static let doseDisclaimer = "Dosage information is gathered from users and various resources. It is not a recommendation and should be verified with other sources for accuracy. Always start with lower doses due to differences between individual body weight, tolerance, metabolism, and personal sensitivity."

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                doseSection
                puritySection
                if isEyeOpen {
                    Section {
                        Button {
                            viewModel.selectedPureDose = nil
                            viewModel.isShowingNext = true
                        } label: {
                            Label("Use Unknown Dose", systemImage: "exclamationmark.triangle")
                        }

                    } footer: {
                        Text("Taking an unknown dose can lead to overdose. Dose your substance with a milligram scale or volumetrically. Test your substance to make sure that it really is what you believe it is and doesn’t contain any dangerous adulterants. If you live in Austria, Belgium, Canada, France, Italy, Netherlands, Spain or Switzerland there are anonymous and free drug testing services available to you, else you can purchase an inexpensive reagent testing kit.")
                    }
                }
                EmptySectionForPadding()
            }
            NavigationLink(
                destination: ChooseTimeAndColor(
                    substanceName: substance.name,
                    administrationRoute: administrationRoute,
                    dose: viewModel.selectedPureDose,
                    units: viewModel.selectedUnits,
                    dismiss: dismiss
                ),
                isActive: $viewModel.isShowingNext,
                label: {
                    Text("Next")
                        .primaryButtonText()
                }
            )
            .padding()
        }
        .navigationBarTitle("Choose Dose")
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
        }
        .task {
            let routeUnits = substance.getDose(for: administrationRoute)?.units
            viewModel.initializeUnits(routeUnits: routeUnits)
        }
    }

    @State private var purityText = "100"
    var purity: Double? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter.number(from: purityText)?.doubleValue
    }

    private var puritySection: some View {
        Section("Purity") {
            VStack {
                HStack {
                    TextField("Enter Purity", text: $purityText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    Text("%")
                }
                HStack {
                    Text("Raw Amount")
                    Spacer()
                    Text(viewModel.impureDoseText)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    var doseSection: some View {
        let roaDose = substance.getDose(for: administrationRoute)
        return Section(
            header: Text("Pure Dose"),
            footer: Text(roaDose?.units != nil ? Self.doseDisclaimer : "")
        ) {
            DoseView(roaDose: roaDose)
            DosePicker(
                roaDose: roaDose,
                doseMaybe: $viewModel.selectedPureDose,
                selectedUnits: $viewModel.selectedUnits
            ).padding(.bottom, 5)
        }
        .listRowSeparator(.hidden)
    }
}

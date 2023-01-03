import SwiftUI

struct ChooseDoseScreen: View {

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dismiss: () -> Void
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ChooseDoseScreenContent(
            substance: substance,
            administrationRoute: administrationRoute,
            dismiss: dismiss,
            selectedPureDose: $viewModel.selectedPureDose,
            selectedUnits: $viewModel.selectedUnits,
            isEstimate: $viewModel.isEstimate,
            isShowingNext: $viewModel.isShowingNext,
            impureDoseText: viewModel.impureDoseText)
        .task {
            let routeUnits = substance.getDose(for: administrationRoute)?.units
            viewModel.initializeUnits(routeUnits: routeUnits)
        }
    }
}

struct ChooseDoseScreenContent: View {

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dismiss: () -> Void
    @Binding var selectedPureDose: Double?
    @Binding var selectedUnits: String?
    @Binding var isEstimate: Bool
    @Binding var isShowingNext: Bool
    var impureDoseText: String

    @State private var isShowingUnknownDoseAlert = false
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false

    var body: some View {
        Form {
            doseSection
            puritySection
            Section {
                Text(Self.doseDisclaimer).font(.footnote)
            }
        }
        .optionalScrollDismissesKeyboard()
        .navigationBarTitle("\(substance.name) Dose")
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
                    if isEyeOpen {
                        isShowingUnknownDoseAlert.toggle()
                    } else {
                        selectedPureDose = nil
                        isShowingNext = true
                    }
                } label: {
                    Label("Use Unknown Dose", systemImage: "exclamationmark.triangle").labelStyle(.titleAndIcon)
                }
                .alert("Unknown Danger", isPresented: $isShowingUnknownDoseAlert) {
                    Button("Log Anyway", role: .destructive) {
                        selectedPureDose = nil
                        isShowingNext = true
                    }
                    Button("Cancel", role: .cancel) {
                        isShowingUnknownDoseAlert.toggle()
                    }
                } message: {
                    Text("Taking an unknown dose can lead to overdose. Dose your substance with a milligram scale or volumetrically. Test your substance to make sure that it really is what you believe it is and doesn’t contain any dangerous adulterants. If you live in Austria, Belgium, Canada, France, Italy, Netherlands, Spain or Switzerland there are anonymous and free drug testing services available to you, else you can purchase an inexpensive reagent testing kit.")
                }
                NavigationLink(
                    destination: FinishIngestionScreen(
                        substanceName: substance.name,
                        administrationRoute: administrationRoute,
                        dose: selectedPureDose,
                        units: selectedUnits,
                        isEstimate: isEstimate,
                        dismiss: dismiss
                    ),
                    isActive: $isShowingNext
                ) {
                    Label("Next", systemImage: "chevron.forward.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }.disabled(selectedPureDose==nil)
            }
        }
    }

    static let doseDisclaimer = "Dosage information is gathered from users and various resources. It is not a recommendation and should be verified with other sources for accuracy. Always start with lower doses due to differences between individual body weight, tolerance, metabolism, and personal sensitivity."

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
                    Text(impureDoseText)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    var doseSection: some View {
        let roaDose = substance.getDose(for: administrationRoute)
        return Section(
            header: Text("Pure Dose"),
            footer: Text(DosesScreen.getUnitClarification(for: roaDose?.units ?? ""))
        ) {
            if let remark = substance.dosageRemark {
                Text(remark)
                    .foregroundColor(.secondary)
            }
            DoseRow(roaDose: roaDose)
            DosePicker(
                roaDose: roaDose,
                doseMaybe: $selectedPureDose,
                selectedUnits: $selectedUnits
            )
            Toggle("Dose is an Estimate", isOn: $isEstimate).tint(.accentColor).padding(.bottom, 5)
        }
        .listRowSeparator(.hidden)
    }
}

struct ChooseDoseScreenContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseDoseScreenContent(
                substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                administrationRoute: .oral,
                dismiss: {},
                selectedPureDose: .constant(20),
                selectedUnits: .constant("mg"),
                isEstimate: .constant(false),
                isShowingNext: .constant(false),
                impureDoseText: "20 mg"
            )
        }
    }
}

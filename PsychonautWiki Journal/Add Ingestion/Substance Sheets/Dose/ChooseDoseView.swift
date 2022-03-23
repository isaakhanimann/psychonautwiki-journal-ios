import SwiftUI

struct ChooseDoseView: View {

    let substance: Substance
    let administrationRoute: AdministrationRoute
    @EnvironmentObject private var sheetViewModel: SheetViewModel
    @StateObject private var viewModel = ViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    // swiftlint:disable line_length
    static let doseDisclaimer = "Dosage information is gathered from users and various resources. It is not a recommendation and should be verified with other sources for accuracy. Always start with lower doses due to differences between individual body weight, tolerance, metabolism, and personal sensitivity."

    var body: some View {
        ZStack {
            regularContent
                .blur(radius: viewModel.isShowingUnknownDoseAlert ? 10 : 0)
                .allowsHitTesting(viewModel.isShowingUnknownDoseAlert ? false : true)
            if viewModel.isShowingUnknownDoseAlert {
                UnknownDoseAlert(viewModel: viewModel)
            }
        }
        .navigationBarTitle("Choose Dose")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    sheetViewModel.dismiss()
                }
            }
        }
        .task {
            let routeUnits = substance.getDose(for: administrationRoute)?.units
            viewModel.initializeUnits(routeUnits: routeUnits)
        }
    }

    var regularContent: some View {
        ZStack(alignment: .bottom) {
            Form {
                doseSection
                if isEyeOpen {
                    HStack {
                        Spacer()
                        Button("Unknown Dose/Purity") {
                            viewModel.isShowingUnknownDoseAlert.toggle()
                        }
                        .buttonStyle(.primary)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                if let impureDoseUnwrap = viewModel.impureDoseRounded {
                    Section(
                        header: Text("Purity")
                    ) {
                        Stepper(
                            "\(viewModel.purity.formatted())%",
                            value: $viewModel.purity,
                            in: 1...100,
                            step: 1
                        )
                        let units = substance.getDose(for: administrationRoute)?.units
                        HStack {
                            Text("Raw Amount")
                            Spacer()
                            Text(impureDoseUnwrap.formatted() + " " + (units ?? ""))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                EmptySectionForPadding()
            }
            let showNavigation = viewModel.selectedPureDose != nil
            NavigationLink(
                destination: ChooseTimeAndColor(
                    substance: substance,
                    administrationRoute: administrationRoute,
                    dose: viewModel.selectedPureDose,
                    units: viewModel.selectedUnits
                ),
                isActive: $viewModel.isShowingNext,
                label: {
                    Text("Next")
                        .primaryButtonText()
                }
            )
                .opacity(showNavigation ? 1 : 0)
                .padding()
        }
    }

    var doseSection: some View {
        let roaDose = substance.getDose(for: administrationRoute)
        return Section(
            header: Text("Pure Dose"),
            footer: Text(roaDose?.unitsUnwrapped != nil ? Self.doseDisclaimer : "")
        ) {
            DoseView(roaDose: roaDose)
            DosePicker(
                roaDose: roaDose,
                doseMaybe: $viewModel.selectedPureDose,
                selectedUnits: $viewModel.selectedUnits
            )
        }
        .listRowSeparator(.hidden)
    }
}

struct ChooseDoseView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        ChooseDoseView(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!
        )
    }
}

import SwiftUI

struct HandleUniversalURLView: View {

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
    ) var storedFile: FetchedResults<SubstancesFile>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var calendarWrapper: CalendarWrapper
    @EnvironmentObject var connectivity: Connectivity

    @State private var alertToShow: Alert?
    @State private var isShowingAlert = false
    @State private var sheetToShow: SheetSelection?

    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    private enum SheetSelection: Identifiable {
        case route(substance: Substance, experience: Experience)
        case dose(route: Roa.AdministrationRoute, substance: Substance, experience: Experience)

        // swiftlint:disable identifier_name
        var id: String {
            switch self {
            case .route(_, _):
                return "route"
            case .dose(_, _, _):
                return "dose"
            }
        }
    }

    var body: some View {
        Text("Show Add Substance")
            .alert(isPresented: $isShowingAlert) {
                alertToShow ?? Alert(
                    title: Text("Error"),
                    message: Text("Something went wrong with request"),
                    dismissButton: .cancel()
                )
            }
            .onOpenURL(perform: { url in
                popToRoot()
                if !isEyeOpen {
                    toggleEye()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    handleUniversalUrl(universalUrl: url)
                }
            })
            .sheet(
                item: $sheetToShow,
                onDismiss: {
                    moc.rollback()
                },
                content: { item in
                    switch item {
                    case .route(let substance, let experience):
                        NavigationView {
                            ChooseRouteView(
                                substance: substance,
                                dismiss: {
                                    self.sheetToShow = nil
                                },
                                experience: experience
                            )
                        }
                        .environment(\.managedObjectContext, self.moc)
                        .environmentObject(calendarWrapper)
                        .environmentObject(connectivity)
                    case .dose(let route, let substance, let experience):
                        NavigationView {
                            ChooseDoseView(
                                substance: substance,
                                administrationRoute: route,
                                dismiss: {
                                    self.sheetToShow = nil
                                },
                                experience: experience
                            )
                        }
                        .environment(\.managedObjectContext, self.moc)
                        .environmentObject(calendarWrapper)
                        .environmentObject(connectivity)
                    }
                }
            )
    }

    private func popToRoot() {
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        keyWindow?.rootViewController?.dismiss(animated: true)
    }

    private func toggleEye() {
        isEyeOpen.toggle()
        connectivity.sendEyeState(isEyeOpen: isEyeOpen)
    }

    private func handleUniversalUrl(universalUrl: URL) {
        if let substanceName = getSubstanceName(from: universalUrl) {
            if let foundSubstance = PersistenceController.shared.getSubstance(with: substanceName) {
                let experience = PersistenceController.shared.getOrCreateLatestExperienceWithoutSave()
                self.alertToShow = Alert(
                    title: Text("Add \(foundSubstance.nameUnwrapped)?")
                        .foregroundColor(Color.red)
                        .font(.title),
                    message: Text("Replace this"),
                    primaryButton: .default(
                        Text("Yes"),
                        action: {
                            addSubstance(substance: foundSubstance, addTo: experience)
                        }
                    ),
                    secondaryButton: .cancel({
                        moc.rollback()
                    })
                )
                self.isShowingAlert = true
            } else {
                self.alertToShow = Alert(
                    title: Text("No Substance Found"),
                    message: Text("Could not find \(substanceName) in substances"),
                    dismissButton: .default(Text("Ok"))
                )
                self.isShowingAlert = true
            }
        } else {
            self.alertToShow = Alert(
                title: Text("No Substance"),
                message: Text("There is no substance specified in the request"),
                dismissButton: .default(Text("Ok"))
            )
            self.isShowingAlert = true
        }
    }

    private func addSubstance(substance: Substance, addTo experience: Experience) {
        if substance.administrationRoutesUnwrapped.count > 1 {
            self.sheetToShow = .route(substance: substance, experience: experience)
        } else {
            guard let firstRoute = substance.administrationRoutesUnwrapped.first else {return}
            self.sheetToShow = .dose(route: firstRoute, substance: substance, experience: experience)
        }

    }

    private func getSubstanceName(from url: URL) -> String? {
        guard let componentsParsed = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else {
            return nil
        }
        guard let queryItemsUnwrapped =  componentsParsed.queryItems else {
            return nil
        }
        return queryItemsUnwrapped.first?.value
    }
}

struct HandleUniversalURLView_Previews: PreviewProvider {
    static var previews: some View {
        HandleUniversalURLView()
    }
}

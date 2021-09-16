import SwiftUI

struct SubstanceRow: View {

    let substance: Substance
    let dismiss: () -> Void
    let experience: Experience

    let dangerousIngestions: [Ingestion]
    let dangerousInteractions: [GeneralInteraction]
    let unsafeIngestions: [Ingestion]
    let unsafeInteractions: [GeneralInteraction]

    var isDangerous: Bool {
        !dangerousIngestions.isEmpty
            || !dangerousInteractions.isEmpty
    }

    var isUnsafe: Bool {
        !unsafeIngestions.isEmpty
            || !unsafeInteractions.isEmpty
    }

    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var isShowingNext = false

    private var isShowingNextBinding: Binding<Bool> {
        Binding(
            get: {
                !isShowingAlert && isShowingNext
            }, set: { _ in
                isShowingNext = false
            }
        )
    }

    init(
        substance: Substance,
        dismiss: @escaping () -> Void,
        experience: Experience
    ) {
        self.substance = substance
        self.dismiss = dismiss
        self.experience = experience

        self.dangerousIngestions = InteractionChecker.getDangerousIngestions(
            of: substance,
            with: experience.sortedIngestionsUnwrapped
        )
        self.dangerousInteractions = InteractionChecker.getDangerousInteraction(of: substance)
        self.unsafeIngestions = InteractionChecker.getUnsafeIngestions(
            of: substance,
            with: experience.sortedIngestionsUnwrapped
        )
        self.unsafeInteractions = InteractionChecker.getUnsafeInteraction(of: substance)
    }

    var body: some View {
        return ZStack {
            if isDangerous || isUnsafe {

                navigationLinkIndirect.hidden()

                Button(
                    action: showAlert,
                    label: {row}
                )
                .alert(isPresented: $isShowingAlert) {
                    Alert(
                        title: Text("Caution")
                            .foregroundColor(Color.red)
                            .font(.title),
                        message: Text(alertMessage),
                        primaryButton: .destructive(
                            Text("Choose Anyway"),
                            action: {
                                isShowingNext = true
                            }
                        ),
                        secondaryButton: .cancel()
                    )
                }
            } else {
                navigationLinkDirect
            }
        }
    }

    @ViewBuilder var navigationLinkIndirect: some View {
        if let route = substance.administrationRoutesUnwrapped.first,
           substance.administrationRoutesUnwrapped.count == 1 {
            NavigationLink(
                destination: ChooseDoseView(
                    substance: substance,
                    administrationRoute: route,
                    dismiss: dismiss,
                    experience: experience
                ),
                isActive: isShowingNextBinding,
                label: {row}
            )
        } else {
            NavigationLink(
                destination: ChooseRouteView(
                    substance: substance,
                    dismiss: dismiss,
                    experience: experience
                ),
                isActive: isShowingNextBinding,
                label: {row}
            )
        }
    }

    @ViewBuilder var navigationLinkDirect: some View {
        if let route = substance.administrationRoutesUnwrapped.first,
           substance.administrationRoutesUnwrapped.count == 1 {
            NavigationLink(
                destination: ChooseDoseView(
                    substance: substance,
                    administrationRoute: route,
                    dismiss: dismiss,
                    experience: experience
                ),
                isActive: $isShowingNext,
                label: {row}
            )
        } else {
            NavigationLink(
                destination: ChooseRouteView(
                    substance: substance,
                    dismiss: dismiss,
                    experience: experience
                ),
                isActive: $isShowingNext,
                label: {row}
            )
        }
    }

    private var row: some View {
        HStack {
            #if os(iOS)
            if let urlUnwrapped = substance.url {
                Link(destination: urlUnwrapped) {
                    Label("\(substance.nameUnwrapped) Website", systemImage: "safari")
                        .labelStyle(IconOnlyLabelStyle())
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
            }
            #endif
            Text(substance.nameUnwrapped)
            Spacer()
            if isDangerous {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
            }
            if isUnsafe {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.yellow)
            }
        }
    }

    private func showAlert() {
        alertMessage = createAlertMessage()
        isShowingAlert.toggle()
    }

    private func createAlertMessage() -> String {

        let isDangerous = !dangerousIngestions.isEmpty
            || !dangerousInteractions.isEmpty
        let isUnsafe = !unsafeIngestions.isEmpty
            || !unsafeInteractions.isEmpty

        assert(isDangerous || isUnsafe)

        var message = ""
        if isDangerous && isUnsafe {
            let dangerNames = getNames(of: dangerousInteractions, and: dangerousIngestions)
            let dangerNamesString = getString(from: dangerNames)
            message += "\(substance.nameUnwrapped) is dangerous with \(dangerNamesString)"
            let unsafeNames = getNames(of: unsafeInteractions, and: unsafeIngestions)
            let unsafeNamesString = getString(from: unsafeNames)
            message += " and unsafe with \(unsafeNamesString)"
            return message
        } else if isDangerous {
            let dangerNames = getNames(of: dangerousInteractions, and: dangerousIngestions)
            let dangerNamesString = getString(from: dangerNames)
            message += "\(substance.nameUnwrapped) is dangerous with \(dangerNamesString)"
            return message
        } else if isUnsafe {
            let unsafeNames = getNames(of: unsafeInteractions, and: unsafeIngestions)
            let unsafeNamesString = getString(from: unsafeNames)
            message += "\(substance.nameUnwrapped) is unsafe with \(unsafeNamesString)"
            return message
        } else {
            assertionFailure("This function should not be called in this case")
            return message
        }
    }

    private func getNames(of interactions: [GeneralInteraction], and ingestions: [Ingestion]) -> [String] {
        var result = [String]()
        for interaction in interactions {
            result.append(interaction.nameUnwrapped)
        }
        for ingestion in ingestions {
            guard let nameUnwrapped = ingestion.substanceCopy?.name else {continue}
            result.append(nameUnwrapped)
        }
        return result.uniqued()
    }

    private func getString(from names: [String]) -> String {
        var result = ""
        for name in names {
            result += "\(name), "
        }
        if result.hasSuffix(", ") {
            result.removeLast(2)
        }
        return result
    }
}

struct SubstanceRow_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper(context: PersistenceController.preview.container.viewContext)
        SubstanceRow(
            substance: helper.substance,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}

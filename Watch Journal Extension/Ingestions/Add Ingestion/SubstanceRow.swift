import SwiftUI

struct SubstanceRow: View {

    let substance: Substance
    let dismiss: () -> Void
    let experience: Experience

    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var isShowingNext = false

    var body: some View {
        let dangerousIngestions = InteractionChecker.getDangerousIngestions(
            of: substance,
            with: experience.sortedIngestionsUnwrapped
        )
        let dangerousInteractions = InteractionChecker.getDangerousInteraction(of: substance)
        let unsafeIngestions = InteractionChecker.getUnsafeIngestions(
            of: substance,
            with: experience.sortedIngestionsUnwrapped
        )
        let unsafeInteractions = InteractionChecker.getUnsafeInteraction(of: substance)

        let isDangerous = !dangerousIngestions.isEmpty
            || !dangerousInteractions.isEmpty
        let isUnsafe = !unsafeIngestions.isEmpty
            || !unsafeInteractions.isEmpty

        return ZStack {
            if substance.administrationRoutesUnwrapped.count == 1 {
                NavigationLink(
                    destination: ChooseDoseView(
                        substance: substance,
                        administrationRoute: substance.administrationRoutesUnwrapped.first!,
                        dismiss: dismiss,
                        experience: experience
                    ),
                    isActive: $isShowingNext,
                    label: {
                        getRow(isDangerous: isDangerous, isUnsafe: isUnsafe)
                    }
                )
            } else {
                NavigationLink(
                    destination: ChooseRouteView(
                        substance: substance,
                        dismiss: dismiss,
                        experience: experience
                    ),
                    isActive: $isShowingNext,
                    label: {
                        getRow(isDangerous: isDangerous, isUnsafe: isUnsafe)
                    }
                )
            }
            if isDangerous || isUnsafe {
                Button(
                    action: {
                        let message = createAlertMessage(
                            substance: substance,
                            dangerousInteractions: dangerousInteractions,
                            dangerousIngestions: dangerousIngestions,
                            unsafeInteractions: unsafeInteractions,
                            unsafeIngestions: unsafeIngestions
                        )
                        showAlert(message: message)
                    }, label: {
                        getRow(isDangerous: isDangerous, isUnsafe: isUnsafe)
                    }
                )
            }
        }
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
    }

    private func getRow(isDangerous: Bool, isUnsafe: Bool) -> some View {
        HStack {
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

    private func showAlert(message: String) {
        alertMessage = message
        isShowingAlert.toggle()
    }

    private func createAlertMessage(
        substance: Substance,
        dangerousInteractions: [GeneralInteraction],
        dangerousIngestions: [Ingestion],
        unsafeInteractions: [GeneralInteraction],
        unsafeIngestions: [Ingestion]
    ) -> String {

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
            result.append(ingestion.substanceCopy!.nameUnwrapped)
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

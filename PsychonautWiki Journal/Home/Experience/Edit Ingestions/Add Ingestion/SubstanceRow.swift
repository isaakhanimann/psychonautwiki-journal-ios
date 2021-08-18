import SwiftUI

struct SubstanceRow: View {

    let substance: Substance
    let chooseSubstanceAndMoveOn: (Substance) -> Void
    var isSelected: Bool = false

    @EnvironmentObject var experience: Experience

    @State private var isShowingAlert = false
    @State private var alertMessage = ""

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

        return Button(
            action: {
                if isDangerous || isUnsafe {
                    let message = createAlertMessage(
                        substance: substance,
                        dangerousInteractions: dangerousInteractions,
                        dangerousIngestions: dangerousIngestions,
                        unsafeInteractions: unsafeInteractions,
                        unsafeIngestions: unsafeIngestions
                    )
                    showAlert(message: message)
                } else {
                    chooseSubstanceAndMoveOn(substance)
                }
            }, label: {
                HStack {
                    Text(substance.nameUnwrapped)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    if isDangerous {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                    if isUnsafe {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.yellow)
                    }
                    if let urlUnwrapped = substance.url {
                        Link(destination: urlUnwrapped) {
                            Label("\(substance.nameUnwrapped) Website", systemImage: "safari")
                                .labelStyle(IconOnlyLabelStyle())
                                .font(.title2)
                        }
                    }
                }
            }
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
                        chooseSubstanceAndMoveOn(substance)
                    }
                ),
                secondaryButton: .cancel()
            )
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
            result.append(ingestion.substance!.nameUnwrapped)
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
            chooseSubstanceAndMoveOn: {_ in }
        )
    }
}

import SwiftUI

struct ChooseColor: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dose: Double
    let dismiss: () -> Void
    let experience: Experience
    let ingestionTime: Date

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var connectivity: Connectivity

    var body: some View {
        ScrollView {
                LazyVGrid(columns: colorColumns) {
                ForEach(Ingestion.IngestionColor.allCases, id: \.self, content: colorButton)
            }
        }
        .navigationBarTitle("Choose Color")
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                Button("Cancel", action: dismiss)
            }
        }
    }

    private func addIngestion(with color: Ingestion.IngestionColor) {
        moc.performAndWait {
            let ingestion = Ingestion(context: moc)
            ingestion.identifier = UUID()
            ingestion.experience = experience
            ingestion.time = ingestionTime
            ingestion.dose = dose
            ingestion.administrationRoute = administrationRoute.rawValue
            ingestion.substanceCopy = SubstanceCopy(basedOn: substance, context: moc)
            ingestion.color = color.rawValue
            substance.lastUsedDate = Date()
            substance.category!.file!.lastUsedSubstance = substance

            connectivity.sendNewIngestion(ingestion: ingestion)
            try? moc.save()
        }

        ComplicationUpdater.updateActiveComplications()
        dismiss()
    }

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    private func colorButton(for color: Ingestion.IngestionColor) -> some View {
        Button(action: {
            addIngestion(with: color)
        }, label: {
            Color.from(ingestionColor: color)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)
        })
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChooseTimeAndColor_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        return ChooseColor(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dose: 10,
            dismiss: {},
            experience: helper.experiences.first!,
            ingestionTime: Date()
        )
    }
}

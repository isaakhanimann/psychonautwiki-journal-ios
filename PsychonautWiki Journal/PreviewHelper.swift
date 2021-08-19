import Foundation
import CoreData

class PreviewHelper {

    let substancesFile: SubstancesFile
    var substance: Substance {
        substancesFile.categoriesUnwrappedSorted.first!.sortedSubstancesUnwrapped.first!
    }
    let experiences: [Experience]

    init(context: NSManagedObjectContext) {
        let controller = PersistenceController.preview
        let moc = controller.container.viewContext

        // Add substance file
        let fileName = "InitialSubstances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }

        // swiftlint:disable force_try
        let data = try! Data(contentsOf: url)

        self.substancesFile = try! SubstanceDecoder.decodeSubstancesFile(from: data, with: moc)

        self.experiences = PreviewHelper.createDefaultExperiences(context: moc, substancesFile: substancesFile)

        try? moc.save()
    }

    // swiftlint:disable function_body_length
    static func createDefaultExperiences(
        context: NSManagedObjectContext,
        substancesFile: SubstancesFile
    ) -> [Experience] {
        let experience1 = Experience(context: context)
        experience1.title = "Day at the Lake"
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .orange,
                stringTime: "2021/08/18 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Myristicin"
            )
        )
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .pink,
                stringTime: "2021/08/18 23:01",
                context: context,
                file: substancesFile,
                substanceName: "Etizolam"
            )
        )
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2021/08/18 23:10",
                context: context,
                file: substancesFile,
                substanceName: "Phenibut"
            )
        )

        let experience2 = Experience(context: context)
        experience2.title = "10 August 2021"
        experience2.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .red,
                stringTime: "2021/08/10 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Dextromethorphan"
            )
        )
        experience2.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .yellow,
                stringTime: "2021/08/10 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Memantine"
            )
        )
        experience2.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .purple,
                stringTime: "2021/08/10 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Adrafinil"
            )
        )

        let experience3 = Experience(context: context)
        experience3.title = "20 Jul 2021"
        experience3.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .green,
                stringTime: "2021/07/20 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Methoxetamine"
            )
        )
        experience3.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .red,
                stringTime: "2021/07/20 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Dextromethorphan"
            )
        )

        let experience4 = Experience(context: context)
        experience4.title = "11 Feb 2021"
        experience4.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .green,
                stringTime: "2021/02/11 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Methoxetamine"
            )
        )
        experience4.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2021/02/11 22:01",
                context: context,
                file: substancesFile,
                substanceName: "PCE"
            )
        )

        let experience5 = Experience(context: context)
        experience5.title = "New Years Eve 2020"
        experience5.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .pink,
                stringTime: "2020/12/31 22:03",
                context: context,
                file: substancesFile,
                substanceName: "2C-C"
            )
        )
        experience5.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .red,
                stringTime: "2020/12/31 22:13",
                context: context,
                file: substancesFile,
                substanceName: "2C-I"
            )
        )

        let experience6 = Experience(context: context)
        experience6.title = "Holiday in Lisbon"
        experience6.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .orange,
                stringTime: "2020/10/10 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Mescaline"
            )
        )

        let experience7 = Experience(context: context)
        experience7.title = "Patrick's Birthday"
        experience7.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2020/06/05 22:03",
                context: context,
                file: substancesFile,
                substanceName: "LSD"
            )
        )
        experience7.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .purple,
                stringTime: "2020/06/05 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Prolintane"
            )
        )
        experience7.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2020/06/05 22:03",
                context: context,
                file: substancesFile,
                substanceName: "DMT"
            )
        )

        let experience8 = Experience(context: context)
        experience8.title = "3 June 2021"
        experience8.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .green,
                stringTime: "2020/06/03 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Methoxetamine"
            )
        )

        let experience9 = Experience(context: context)
        experience9.title = "Night in Lagos"
        experience9.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .yellow,
                stringTime: "2020/03/11 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Memantine"
            )
        )
        experience9.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .purple,
                stringTime: "2020/03/11 22:03",
                context: context,
                file: substancesFile,
                substanceName: "MDA"
            )
        )

        return [
            experience1,
            experience2,
            experience3,
            experience4,
            experience5,
            experience6,
            experience8,
            experience9
        ]
    }

    static private func createDefaultIngestion(
        with color: Ingestion.IngestionColor,
        stringTime: String,
        context: NSManagedObjectContext,
        file: SubstancesFile,
        substanceName: String,
        dose: Double = 10
    ) -> Ingestion {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let substance = file.getSubstance(with: substanceName)!

        let ingestion = Ingestion(context: context)
        ingestion.time = formatter.date(from: stringTime)
        ingestion.administrationRoute = substance.administrationRoutesUnwrapped.first!.rawValue
        ingestion.dose = dose
        ingestion.color = color.rawValue
        ingestion.substanceCopy = SubstanceCopy(
            basedOn: substance,
            context: context
        )
        return ingestion
    }
}

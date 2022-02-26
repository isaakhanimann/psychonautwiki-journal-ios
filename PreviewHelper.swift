import Foundation
import CoreData

class PreviewHelper {

    let substancesFile: SubstancesFile
    var substance: Substance {
        substancesFile.psychoactiveClassesUnwrapped.first!.sortedSubstancesUnwrapped.first!
    }
    let experiences: [Experience]

    init(context: NSManagedObjectContext) {
        let controller = PersistenceController.preview
        let moc = controller.viewContext

        // Add substance file
        let fileName = "InitialSubstances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }

        // swiftlint:disable force_try
        let data = try! Data(contentsOf: url)

        self.substancesFile = try! decodeSubstancesFile(from: data, with: moc)

        self.experiences = PreviewHelper.createDefaultExperiences(context: moc, substancesFile: substancesFile)

        try? moc.save()
    }

    // swiftlint:disable function_body_length
    static func createDefaultExperiences(
        context: NSManagedObjectContext,
        substancesFile: SubstancesFile
    ) -> [Experience] {
        let experience1 = Experience(context: context)
        experience1.title = "18 Aug 2021"
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .red,
                stringTime: "2021/08/18 08:01",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine",
                dose: 100
            )
        )
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2021/08/18 09:10",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine",
                dose: 200
            )
        )
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .green,
                stringTime: "2021/08/18 11:10",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine",
                dose: 150
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
                substanceName: "Caffeine"
            )
        )
        experience2.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .yellow,
                stringTime: "2021/08/10 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Myristicin"
            )
        )
        experience2.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .purple,
                stringTime: "2021/08/10 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
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
                substanceName: "Caffeine"
            )
        )
        experience3.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .red,
                stringTime: "2021/07/20 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
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
                substanceName: "Caffeine"
            )
        )
        experience4.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2021/02/11 22:01",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
            )
        )

        let experience5 = Experience(context: context)
        experience5.title = "31 Dec 2020"
        experience5.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .pink,
                stringTime: "2020/12/31 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
            )
        )
        experience5.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .red,
                stringTime: "2020/12/31 22:13",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
            )
        )

        let experience6 = Experience(context: context)
        experience6.title = "10 Oct 2020"
        experience6.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .orange,
                stringTime: "2020/10/10 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
            )
        )

        let experience7 = Experience(context: context)
        experience7.title = "5 Jun 2020"
        experience7.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2020/06/05 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
            )
        )
        experience7.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .purple,
                stringTime: "2020/06/05 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
            )
        )
        experience7.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2020/06/05 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
            )
        )

        let experience8 = Experience(context: context)
        experience8.title = "3 Jun 2020"
        experience8.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .green,
                stringTime: "2020/06/03 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
            )
        )

        let experience9 = Experience(context: context)
        experience9.title = "11 Mar 2020"
        experience9.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .yellow,
                stringTime: "2020/03/11 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Citicoline"
            )
        )
        experience9.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .purple,
                stringTime: "2020/03/11 22:03",
                context: context,
                file: substancesFile,
                substanceName: "Caffeine"
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
        let substance = PersistenceController.preview.getSubstance(with: substanceName)!

        let ingestion = Ingestion(context: context)
        ingestion.time = formatter.date(from: stringTime)
        ingestion.administrationRoute = substance.administrationRoutesUnwrapped.first!.rawValue
        ingestion.dose = dose
        ingestion.color = color.rawValue
        ingestion.substanceName = substanceName
        return ingestion
    }
}

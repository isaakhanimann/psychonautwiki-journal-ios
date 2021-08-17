import Foundation
import CoreData

class PreviewHelper {

    let substancesFile: SubstancesFile
    var substance: Substance {
        substancesFile.categoriesUnwrappedSorted.first!.sortedSubstancesUnwrapped.first!
    }
    let experiences: [Experience]

    // swiftlint:disable function_body_length
    init(context: NSManagedObjectContext) {
        let controller = PersistenceController.preview
        let moc = controller.container.viewContext

        // Add substance file
        let fileName = "Sample Substances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }

        // swiftlint:disable force_try
        let data = try! Data(contentsOf: url)

        self.substancesFile = try! SubstanceDecoder.decodeSubstancesFile(from: data, with: moc)

        // Add experiences

        let experience1 = Experience(context: moc)
        experience1.title = "Day at the Lake"
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .orange,
                stringTime: "2020/02/01 22:01",
                context: moc,
                file: substancesFile
            )
        )
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .pink,
                stringTime: "2020/02/01 22:02",
                context: moc,
                file: substancesFile
            )
        )
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2020/02/01 22:03",
                context: moc,
                file: substancesFile
            )
        )

        let experience2 = Experience(context: moc)
        experience2.title = "10 March 2020"
        experience2.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .orange,
                stringTime: "2020/03/10 22:01",
                context: moc,
                file: substancesFile
            )
        )
        experience2.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .pink,
                stringTime: "2020/03/10 22:02",
                context: moc,
                file: substancesFile
            )
        )
        experience2.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .purple,
                stringTime: "2020/03/10 22:03",
                context: moc,
                file: substancesFile
            )
        )

//        let experience3 = Experience(context: moc)
//        experience3.title = "New Years Eve 2020"
//        experience3.addToIngestions(createDefaultIngestion(with: .orange))
//        experience3.addToIngestions(createDefaultIngestion(with: .orange))
//
//        let experience4 = Experience(context: moc)
//        experience4.title = "11 Feb 2021"
//        experience4.addToIngestions(createDefaultIngestion(with: .purple))
//        experience4.addToIngestions(createDefaultIngestion(with: .orange))
//        experience4.addToIngestions(createDefaultIngestion(with: .purple))
//
//        let experience5 = Experience(context: moc)
//        experience5.title = "20 May 2021"
//        experience5.addToIngestions(createDefaultIngestion(with: .pink))
//        experience5.addToIngestions(createDefaultIngestion(with: .pink))
//        experience5.addToIngestions(createDefaultIngestion(with: .orange))
//
//        let experience6 = Experience(context: moc)
//        experience6.title = "Holiday in Lisbon"
//        experience6.addToIngestions(createDefaultIngestion(with: .pink))
//
//        let experience7 = Experience(context: moc)
//        experience7.title = "Patrick's Birthday"
//        experience7.addToIngestions(createDefaultIngestion(with: .pink))
//        experience7.addToIngestions(createDefaultIngestion(with: .pink))
//        experience7.addToIngestions(createDefaultIngestion(with: .purple))
//
//        let experience8 = Experience(context: moc)
//        experience8.title = "25 June 2021"
//        experience8.addToIngestions(createDefaultIngestion(with: .purple))
//
//        let experience9 = Experience(context: moc)
//        experience9.title = "Night in Lagos"
//        experience9.addToIngestions(createDefaultIngestion(with: .orange))
//        experience9.addToIngestions(createDefaultIngestion(with: .pink))
//        experience9.addToIngestions(createDefaultIngestion(with: .pink))
//
//        let experience10 = Experience(context: moc)
//        experience10.title = "Day at the Lake 2.0"
//        experience10.addToIngestions(createDefaultIngestion(with: .pink))
//        experience10.addToIngestions(createDefaultIngestion(with: .pink))
//        experience10.addToIngestions(createDefaultIngestion(with: .purple))
//        experience10.addToIngestions(createDefaultIngestion(with: .orange))
//        experience10.addToIngestions(createDefaultIngestion(with: .pink))
//        experience10.addToIngestions(createDefaultIngestion(with: .orange))
//
//        let experience11 = Experience(context: moc)
//        experience11.title = "5 Jul 2021"
//        experience11.addToIngestions(createDefaultIngestion(with: .purple))
//        experience11.addToIngestions(createDefaultIngestion(with: .pink))
//        experience11.addToIngestions(createDefaultIngestion(with: .orange))
//
//        let experience12 = Experience(context: moc)
//        experience12.title = "20 Jul 2021"
//        experience12.addToIngestions(createDefaultIngestion(with: .orange))
//        experience12.addToIngestions(createDefaultIngestion(with: .pink))
//
//        let experience13 = Experience(context: moc)
//        experience13.title = "Surf Camp"
//        experience13.addToIngestions(createDefaultIngestion(with: .orange))
//        experience13.addToIngestions(createDefaultIngestion(with: .orange))
//
//        let experience14 = Experience(context: moc)
//        experience14.title = "28 Jul 2021"
//        experience14.addToIngestions(createDefaultIngestion(with: .purple))
//        experience14.addToIngestions(createDefaultIngestion(with: .pink))
//        experience14.addToIngestions(createDefaultIngestion(with: .orange))
//
//        let experience15 = Experience(context: moc)
//        experience15.title = "Steffanie's Going Away Party"
//        experience15.addToIngestions(createDefaultIngestion(with: .pink))
//
//        let experience16 = Experience(context: moc)
//        experience16.title = "10 Aug 2021"
//        experience16.addToIngestions(createDefaultIngestion(with: .purple))
//        experience16.addToIngestions(createDefaultIngestion(with: .purple))
//
//        let experience17 = Experience(context: moc)
//        experience17.title = "Ultra Festival"
//        experience17.addToIngestions(createDefaultIngestion(with: .blue))
//
//        let experience18 = Experience(context: moc)
//        experience18.title = "Evening at Jonathan's"
//        experience18.addToIngestions(createDefaultIngestion(with: .blue))
//        experience18.addToIngestions(createDefaultIngestion(with: .purple))
//        experience18.addToIngestions(createDefaultIngestion(with: .blue))
//        experience18.addToIngestions(createDefaultIngestion(with: .blue))
//
//        let experience19 = Experience(context: moc)
//        experience19.title = "5 Sept 2021"
//        experience19.addToIngestions(createDefaultIngestion(with: .pink))
//        experience19.addToIngestions(createDefaultIngestion(with: .blue))
//
//        let experience20 = Experience(context: moc)
//        experience20.title = "21 Sept 2021"
//        experience20.addToIngestions(createDefaultIngestion(with: .pink))
//        experience20.addToIngestions(createDefaultIngestion(with: .pink))
//        experience20.addToIngestions(createDefaultIngestion(with: .purple))

        self.experiences = [
            experience1,
            experience2
//            experience3,
//            experience4,
//            experience5,
//            experience6,
//            experience8,
//            experience9,
//            experience10,
//            experience11,
//            experience12,
//            experience13,
//            experience14,
//            experience15,
//            experience16,
//            experience17,
//            experience18,
//            experience19,
//            experience20
        ]

        try? moc.save()
    }

    static private func createDefaultIngestion(
        with color: Ingestion.IngestionColor,
        stringTime: String,
        context: NSManagedObjectContext,
        file: SubstancesFile
    ) -> Ingestion {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"

            let ingestion = Ingestion(context: context)
            ingestion.time = formatter.date(from: stringTime)
            ingestion.administrationRoute = Roa.AdministrationRoute.oral.rawValue
            ingestion.dose = 10
            ingestion.color = color.rawValue
        ingestion.substance = file.categoriesUnwrappedSorted.first!.sortedSubstancesUnwrapped.first!
            return ingestion
        }
}

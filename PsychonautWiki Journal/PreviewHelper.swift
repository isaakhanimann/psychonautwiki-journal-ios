import Foundation
import CoreData

// swiftlint:disable type_body_length
class PreviewHelper {

    static let shared = PreviewHelper()

    var allSubstances: [Substance] {
        let fetchRequest = Substance.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Substance.name, ascending: true) ]
        let substances = try? context.fetch(fetchRequest)
        return substances ?? []
    }
    var unresolvedInteractions: [UnresolvedInteraction] {
        let fetchRequest = UnresolvedInteraction.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \UnresolvedInteraction.name, ascending: true) ]
        let unresolved = try? context.fetch(fetchRequest)
        return unresolved ?? []
    }
    var allEffects: [Effect] {
        let fetchRequest = Effect.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Effect.name, ascending: true) ]
        let effects = try? context.fetch(fetchRequest)
        return effects ?? []
    }
    var substance: Substance {
        allSubstances.first!
    }
    let experiences: [Experience]
    let preset: Preset
    let customSubstance: CustomSubstance
    let file: SubstancesFile
    let context: NSManagedObjectContext
    var psychoactives: [PsychoactiveClass] {
        file.psychoactiveClassesUnwrapped
    }
    var chemicals: [ChemicalClass] {
        file.chemicalClassesUnwrapped
    }

    func getSubstance(with name: String) -> Substance? {
        allSubstances.first(where: {$0.nameUnwrapped == name})
    }

    init() {
        let fileName = "InitialSubstances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }
        // swiftlint:disable force_try
        let data = try! Data(contentsOf: url)
        self.context = PersistenceController.preview.viewContext
        self.file = try! decodeSubstancesFile(from: data, with: context)
        self.experiences = Self.createDefaultExperiences(context: context)
        self.preset = Self.createDefaultPreset(context: context)
        self.customSubstance = Self.createDefaultCustomSubstance(context: context)
        try? context.save()
    }

    // swiftlint:disable function_body_length
    static func createDefaultExperiences(context: NSManagedObjectContext) -> [Experience] {
        let experience1 = Experience(context: context)
        experience1.title = "18 Aug 2021"
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .red,
                stringTime: "2021/08/18 08:01",
                context: context,
                substanceName: "Caffeine",
                dose: 100
            )
        )
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2021/08/18 09:10",
                context: context,
                substanceName: "Caffeine",
                dose: 200
            )
        )
        experience1.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .green,
                stringTime: "2021/08/18 11:10",
                context: context,
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
                substanceName: "Caffeine"
            )
        )
        experience2.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .yellow,
                stringTime: "2021/08/10 22:01",
                context: context,
                substanceName: "Myristicin"
            )
        )
        experience2.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .purple,
                stringTime: "2021/08/10 22:01",
                context: context,
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
                substanceName: "Caffeine"
            )
        )
        experience3.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .red,
                stringTime: "2021/07/20 22:01",
                context: context,
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
                substanceName: "Caffeine"
            )
        )
        experience4.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2021/02/11 22:01",
                context: context,
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
                substanceName: "Caffeine"
            )
        )
        experience5.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .red,
                stringTime: "2020/12/31 22:13",
                context: context,
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
                substanceName: "Caffeine"
            )
        )
        experience7.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .purple,
                stringTime: "2020/06/05 22:03",
                context: context,
                substanceName: "Caffeine"
            )
        )
        experience7.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .blue,
                stringTime: "2020/06/05 22:03",
                context: context,
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
                substanceName: "Citicoline"
            )
        )
        experience9.addToIngestions(
            PreviewHelper.createDefaultIngestion(
                with: .purple,
                stringTime: "2020/03/11 22:03",
                context: context,
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
        with color: IngestionColor,
        stringTime: String,
        context: NSManagedObjectContext,
        substanceName: String,
        dose: Double = 10
    ) -> Ingestion {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let substance = PersistenceController.preview.getSubstance(with: substanceName)!
        let ingestion = Ingestion(context: context)
        ingestion.time = formatter.date(from: stringTime)
        let route = substance.administrationRoutesUnwrapped.first!
        ingestion.administrationRoute = route.rawValue
        ingestion.units = substance.getDose(for: route)?.units
        ingestion.dose = dose
        ingestion.color = color.rawValue
        ingestion.substanceName = substanceName
        return ingestion
    }

    static func createDefaultPreset(context: NSManagedObjectContext) -> Preset {
        let preset = Preset(context: context)
        preset.name = "Malboro Gold"
        preset.units = "cigarettes"
        let component = PresetComponent(context: context)
        component.units = "mg"
        component.substanceName = "Nicotine"
        component.administrationRoute = AdministrationRoute.smoked.rawValue
        component.dosePerUnitOfPreset = 0.5
        preset.addToComponents(component)
        return preset
    }

    static func createDefaultCustomSubstance(context: NSManagedObjectContext) -> CustomSubstance {
        let custom = CustomSubstance(context: context)
        custom.name = "My Custom Substance"
        custom.units = "puff"
        return custom
    }
}

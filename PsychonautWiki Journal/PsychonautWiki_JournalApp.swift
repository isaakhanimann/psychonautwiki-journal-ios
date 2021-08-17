import SwiftUI
import SwiftyJSON

// swiftlint:disable type_name
@main
struct PsychonautWiki_JournalApp: App {

    let persistenceController = PersistenceController.shared
    @StateObject var calendarWrapper = CalendarWrapper()
    @StateObject var importSubstancesWrapper = SubstanceLinksWrapper()

    var body: some Scene {
        WindowGroup {
            Button("Fetch") {
                PsychonautWikiAPIController.performRequest { result in
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(let data):
                        printData(data: data)
                    }
                }
            }
            //            ContentView()
            //                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            //                .environmentObject(calendarWrapper)
//                .environmentObject(importSubstancesWrapper)
//                .accentColor(Color.orange)
        }
    }

    struct JSONFile: Decodable {
        let data: SubstancesList
    }

    struct SubstancesList: Decodable {
        let substances: [Substance]
    }

    struct Substance: Decodable {
        let name: String
    }

    private func printData(data: Data) {

        do {
            let json = try JSON(data: data)
            print(json["data"]["substances"].debugDescription)
        } catch {
            print("Failed to decode")
        }
    }
}

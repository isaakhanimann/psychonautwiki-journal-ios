import Foundation

class SheetViewModel: ObservableObject {

    @Published var sheetToShow: SheetOption?

    enum SheetOption: Identifiable {
        // swiftlint:disable identifier_name
        var id: String {
            switch self {
            case .addIngestionFromContent(let foundSubstance):
                return "addIngestionFromContent" + foundSubstance.name
            case .addIngestionFromExperience(let experience):
                return "addIngestionFromExperience" + experience.creationDateUnwrappedString
            case .addIngestionFromSubstance(let substance):
                return "addIngestionFromSearch" + substance.name
            case .addIngestionFromCustom(let custom):
                return "addIngestionFromCustom" + custom.nameUnwrapped
            case .addCustom:
                return "addCustom"
            case .article(let url):
                return "article" + url.absoluteString
            }
        }
        case addIngestionFromContent(foundSubstance: Substance)
        case addIngestionFromExperience(experience: Experience)
        case addIngestionFromSubstance(substance: Substance)
        case addIngestionFromCustom(custom: CustomSubstance)
        case addCustom
        case article(url: URL)
    }

    func dismiss() {
        sheetToShow = nil
    }
}

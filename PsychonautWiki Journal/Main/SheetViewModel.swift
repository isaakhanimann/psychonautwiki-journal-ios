import Foundation

class SheetViewModel: ObservableObject {

    @Published var sheetToShow: SheetOption?

    enum SheetOption: Identifiable {
        // swiftlint:disable identifier_name
        var id: String {
            switch self {
            case .addIngestionFromContent(let foundSubstance):
                return "addIngestionFromContent" + foundSubstance.nameUnwrapped
            case .addIngestionFromExperience(let experience):
                return "addIngestionFromExperience" + experience.creationDateUnwrappedString
            case .addIngestionFromSubstance(let substance):
                return "addIngestionFromSearch" + substance.nameUnwrapped
            case .addIngestionFromPreset(let preset):
                return "addIngestionFromPreset" + preset.nameUnwrapped
            case .addIngestionFromCustom(let custom):
                return "addIngestionFromCustom" + custom.nameUnwrapped
            case .addPreset:
                return "addPreset"
            case .addCustom:
                return "addCustom"
            case .article(let url):
                return "article" + url.absoluteString
            }
        }

        case addIngestionFromContent(foundSubstance: Substance)
        case addIngestionFromExperience(experience: Experience)
        case addIngestionFromSubstance(substance: Substance)
        case addIngestionFromPreset(preset: Preset)
        case addIngestionFromCustom(custom: CustomSubstance)
        case addPreset
        case addCustom
        case article(url: URL)
    }

    func dismiss() {
        sheetToShow = nil
    }
}

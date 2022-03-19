import SwiftUI

extension SubstanceView {
    enum SheetType: Identifiable, Equatable {
        // swiftlint:disable identifier_name
        var id: String {
            switch self {
            case .addIngestion:
                return "addIngestion"
            case .article(let url):
                return "addArticle+\(url.path)"
            }
        }

        case addIngestion, article(url: URL)
    }
    class ViewModel: ObservableObject {
        @Published var sheetToShow: SheetType?
        @Published var isShowingSuccessToast = false
        var isShowingIngestion: Binding<Bool> {
            Binding {
                self.sheetToShow == .addIngestion
            } set: {
                if !$0 {
                    self.sheetToShow = nil
                }
            }
        }
    }
}

import Foundation

protocol InteractionAlertable {
    var dangerousIngestions: [Ingestion] { get }
    var unsafeIngestions: [Ingestion] { get }
    var uncertainIngestions: [Ingestion] { get }
    func hideAlert()
    func showNext()
}

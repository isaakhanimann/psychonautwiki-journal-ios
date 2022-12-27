import SwiftUI
import StoreKit

struct RateInAppStoreButton: View {
    var body: some View {
        Button {
            if let windowScene = UIApplication.shared.currentWindow?.windowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        } label: {
            Label("Rate in App Store", systemImage: "star")
        }
    }
}

struct RateInAppStoreButton_Previews: PreviewProvider {
    static var previews: some View {
        RateInAppStoreButton()
    }
}

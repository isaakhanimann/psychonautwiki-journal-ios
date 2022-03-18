import SwiftUI

struct ShareButton: View {
    var body: some View {
        Button {
            let controller = UIActivityViewController(
                activityItems: [
                    URL(string: "https://apps.apple.com/ch/app/psychonautwiki-journal/id1582059415?l=en")!
                ],
                applicationActivities: nil
            )
            UIApplication.shared.currentWindow?.rootViewController?.present(
                controller,
                animated: true,
                completion: nil
            )
        } label: {
            Label("Share With a Friend", systemImage: "square.and.arrow.up")
        }
    }
}

struct ShareButton_Previews: PreviewProvider {
    static var previews: some View {
        ShareButton()
    }
}

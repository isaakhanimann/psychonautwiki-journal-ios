import SwiftUI

struct FullDisclaimerView: View {

    @Environment(\.presentationMode) var presentationMode

    // swiftlint:disable line_length
    var body: some View {
        NavigationView {
            ScrollView {
                Text("""
                    Whilst the developer of Goya endeavours to keep the linked substance information up to date and correct, he makes no representations or warranties of any kind, expressed or implied about the completeness, accuracy, reliability, suitability or availability. Any reliance you place on the linked substance information is therefore strictly at your own risk.

                    He will not be liable for any false, inaccurate, inappropriate or incomplete information presented in the app.

                    He takes no responsibility for any loss or damage suffered as a result of the use of, or inability to use or access the Goya app whatsoever.

                    In no circumstances shall he be liable to you or any other third parties for any loss or damage arising directly or indirectly from your use of or inability to use, this app or any of the material contained in it.
                """)
            }
            .padding()
            .navigationTitle("Disclaimer")
            .navigationBarItems(trailing: Button("Done", action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
    }
}

struct FullDisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        FullDisclaimerView()
    }
}

import SwiftUI

struct HandleUniversalURLView: View {

    @State private var alertToShow: Alert?
    @State private var isShowingAlert = false
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        Text("Show Add Substance")
            .alert(isPresented: $isShowingAlert) {
                alertToShow ?? Alert(
                    title: Text("Error"),
                    message: Text("Something went wrong with request"),
                    dismissButton: .cancel()
                )
            }
            .onOpenURL(perform: { url in
                popToRoot()
                if !isEyeOpen {
                    toggleEye()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    handleUniversalUrl(universalUrl: url)
                }
            })
    }

    private func popToRoot() {
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        keyWindow?.rootViewController?.dismiss(animated: true)
    }

    private func toggleEye() {
        isEyeOpen.toggle()
        Connectivity.shared.sendEyeState(isEyeOpen: isEyeOpen)
    }

    private func handleUniversalUrl(universalUrl: URL) {
        if let substanceName = getSubstanceName(from: universalUrl) {
            if let foundSubstance = PersistenceController.shared.getSubstance(with: substanceName) {
                print(foundSubstance)
            } else {
                self.alertToShow = Alert(
                    title: Text("No Substance Found"),
                    message: Text("Could not find \(substanceName) in substances"),
                    dismissButton: .default(Text("Ok"))
                )
                self.isShowingAlert = true
            }
        } else {
            self.alertToShow = Alert(
                title: Text("No Substance"),
                message: Text("There is no substance specified in the request"),
                dismissButton: .default(Text("Ok"))
            )
            self.isShowingAlert = true
        }
    }

    private func getSubstanceName(from url: URL) -> String? {
        guard let componentsParsed = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else {
            return nil
        }
        guard let queryItemsUnwrapped =  componentsParsed.queryItems else {
            return nil
        }
        return queryItemsUnwrapped.first?.value
    }
}

struct HandleUniversalURLView_Previews: PreviewProvider {
    static var previews: some View {
        HandleUniversalURLView()
    }
}

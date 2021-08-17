import SwiftUI

struct DownloadErrorView: View {

    @Binding var isThereAnErrorWithDownload: Bool
    let errorMessage: String

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 30) {
                Text("Substance Import Failed")
                    .lineLimit(2)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
                Image(systemName: "xmark.octagon.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.red)
                    .frame(width: 70, height: 70)
                Text(errorMessage)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Ok") {
                    self.isThereAnErrorWithDownload.toggle()
                }
                .buttonStyle(PrimaryButtonStyle())
                .font(.title2)
            }
            .padding()
        }
        .currentDeviceNavigationViewStyle()
    }
}

struct DownloadErrorView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadErrorView(
            isThereAnErrorWithDownload: .constant(false),
            errorMessage: "Some reason why it failed"
        )
    }
}

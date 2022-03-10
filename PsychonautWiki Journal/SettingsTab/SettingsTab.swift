import SwiftUI
import AlertToast
import StoreKit

struct SettingsTab: View {

    @StateObject private var viewModel = ViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            List {
                eye
                Section(header: Text("Last Successfull Substance Fetch")) {
                    HStack(spacing: 10) {
                        if viewModel.isFetching {
                            ProgressView()
                            Text("Fetching Substances")
                                .foregroundColor(.secondary)
                        } else {
                            Button(action: viewModel.fetchNewSubstances, label: {
                                Label(
                                    viewModel.substancesFile?.creationDateUnwrapped.asDateAndTime ?? "No Substances",
                                    systemImage: "arrow.clockwise"
                                )
                            })
                        }
                    }
                }
                Section(header: Text("Safety")) {
                    Link(destination: URL(string: "https://psychonautwiki.org/wiki/Responsible_drug_use")!) {
                        Label("Responsible Use", systemImage: "brain")
                    }
                }
                Section("Communication") {
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
                    Link(destination: URL(string: "https://t.me/isaakhanimann")!) {
                        Label("Feature Requests / Bug Reports", systemImage: "exclamationmark.bubble")
                    }
                    Button {
                        if let windowScene = UIApplication.shared.currentWindow?.windowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    } label: {
                        Label("Rate in App Store", systemImage: "star")
                    }
                    Link(destination: URL(string: "https://t.me/isaakhanimann")!) {
                        Label("Ask a Question", systemImage: "ellipsis.bubble")
                    }
                    NavigationLink(
                        destination: FAQView(),
                        label: {
                            Label("Frequently Asked Questions", systemImage: "questionmark.square")
                        }
                    )
                        .foregroundColor(.accentColor)
                }
            }
            .navigationTitle("Settings")
            .toast(isPresenting: $viewModel.isShowingErrorAlert) {
                AlertToast(
                    displayMode: .alert,
                    type: .error(Color.red),
                    title: "Try Again Later"
                )
            }
        }
    }

    private var eye: some View {
        HStack {
            Spacer()
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80, alignment: .center)
                .onTapGesture(count: 3, perform: toggleEye)
            Spacer()
        }
        .listRowBackground(Color.clear)
    }

    private var imageName: String {
        isEyeOpen ? "Eye Open" : "Eye Closed"
    }

    private func toggleEye() {
        isEyeOpen.toggle()
        playHapticFeedback()
        Connectivity.shared.sendEyeState(isEyeOpen: isEyeOpen)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}

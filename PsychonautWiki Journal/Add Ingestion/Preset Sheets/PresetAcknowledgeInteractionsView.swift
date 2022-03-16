import SwiftUI

struct PresetAcknowledgeInteractionsView: View {

    let preset: Preset
    let dismiss: (AddResult) -> Void
    let experience: Experience?
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            regularContent
                .blur(radius: viewModel.isShowingAlert ? 10 : 0)
                .allowsHitTesting(viewModel.isShowingAlert ? false : true)
            if viewModel.isShowingAlert {
                InteractionAlertView(alertable: viewModel)
            }
        }
        .task {
            viewModel.checkInteractionsWith(preset: preset)
        }
    }

    var regularContent: some View {
        ZStack(alignment: .bottom) {
            List {
                PresetInteractionsSection(preset: preset)
                bottomPadding
            }
            Button("Next") {
                viewModel.pressNext()
            }
            .buttonStyle(.primary)
            .padding()
            NavigationLink("Next", isActive: $viewModel.isShowingNext) {
                PresetChooseDoseView(
                    preset: preset,
                    dismiss: dismiss,
                    experience: experience
                )
            }
            .allowsHitTesting(false)
            .hidden()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss(.cancelled)
                }
            }
        }
        .navigationBarTitle(preset.nameUnwrapped)
    }

    var bottomPadding: some View {
        Section(header: Text("")) {
            EmptyView()
        }
    }
}

struct PresetAcknowledgeInteractionsView_Previews: PreviewProvider {
    static var previews: some View {
        PresetAcknowledgeInteractionsView(
            preset: PreviewHelper.shared.preset,
            dismiss: {print($0)},
            experience: nil
        )
    }
}

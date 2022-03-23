import SwiftUI

struct PresetAcknowledgeInteractionsView: View {

    let preset: Preset
    @EnvironmentObject private var sheetViewModel: SheetViewModel
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
                EmptySectionForPadding()
            }
            Button("Next") {
                viewModel.pressNext()
            }
            .buttonStyle(.primary)
            .padding()
            NavigationLink("Next", isActive: $viewModel.isShowingNext) {
                PresetChooseDoseView(preset: preset)
            }
            .allowsHitTesting(false)
            .hidden()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    sheetViewModel.dismiss()
                }
            }
        }
        .navigationBarTitle(preset.nameUnwrapped)
    }
}

struct PresetAcknowledgeInteractionsView_Previews: PreviewProvider {
    static var previews: some View {
        PresetAcknowledgeInteractionsView(preset: PreviewHelper.shared.preset)
    }
}

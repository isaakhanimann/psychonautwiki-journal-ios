import SwiftUI

struct AcknowledgeInteractionsView: View {

    let substance: Substance
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
            viewModel.checkInteractionsWith(substance: substance)
        }
    }

    var regularContent: some View {
        ZStack(alignment: .bottom) {
            List {
                InteractionsSection(substance: substance)
                EmptySectionForPadding()
            }
            Button("Next") {
                viewModel.pressNext()
            }
            .buttonStyle(.primary)
            .padding()
            NavigationLink("Next", isActive: $viewModel.isShowingNext) {
                ChooseRouteView(substance: substance)
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
        .navigationBarTitle(substance.nameUnwrapped)
    }
}

struct AcknowledgeInteractionsView_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgeInteractionsView(
            substance: PreviewHelper.shared.getSubstance(with: "Caffeine")!
        )
    }
}

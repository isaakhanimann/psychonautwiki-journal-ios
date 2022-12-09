import SwiftUI

struct AcknowledgeInteractionsView: View {

    let substance: Substance
    let dismiss: DismissAction
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
                if let interactions = substance.interactions {
                    InteractionSection(interactions: interactions, substanceURL: substance.url)
                } else {
                    Text("There are no documented interactions")
                }
                EmptySectionForPadding()
            }
            Button("Next") {
                viewModel.pressNext()
            }
            .buttonStyle(.primary)
            .padding()
            NavigationLink("Next", isActive: $viewModel.isShowingNext) {
                ChooseRouteView(substance: substance, dismiss: dismiss)
            }
            .allowsHitTesting(false)
            .hidden()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .navigationBarTitle(substance.name + " Interactions")
    }
}

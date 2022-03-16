import SwiftUI

struct AcknowledgeInteractionsView: View {

    let substance: Substance
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
            viewModel.checkInteractionsWith(substance: substance)
        }
    }

    var regularContent: some View {
        ZStack(alignment: .bottom) {
            List {
                InteractionsSection(substance: substance)
                bottomPadding
            }
            Button("Next") {
                viewModel.pressNext()
            }
            .buttonStyle(.primary)
            .padding()
            NavigationLink("Next", isActive: $viewModel.isShowingNext) {
                ChooseRouteView(
                    substance: substance,
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
        .navigationBarTitle(substance.nameUnwrapped)
    }

    var bottomPadding: some View {
        Section(header: Text("")) {
            EmptyView()
        }
    }
}

struct AcknowledgeInteractionsView_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgeInteractionsView(
            substance: PreviewHelper.shared.getSubstance(with: "Caffeine")!,
            dismiss: {print($0)},
            experience: nil
        )
    }
}

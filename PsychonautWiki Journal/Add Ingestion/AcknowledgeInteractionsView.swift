import SwiftUI

struct AcknowledgeInteractionsView: View {

    let substance: Substance
    let dismiss: (AddResult) -> Void
    let experience: Experience?
    @State private var isShowingAlert = false
    @State private var isShowingNext = false
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            regularContent
                .blur(radius: isShowingAlert ? 10 : 0)
                .allowsHitTesting(isShowingAlert ? false : true)
            if isShowingAlert {
                alertView
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
            }
            Button("Next") {
                if viewModel.hasInteractions {
                    isShowingAlert = true
                } else {
                    isShowingNext = true
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding()
            NavigationLink("Next", isActive: $isShowingNext) {
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

    var alertView: some View {
        VStack(alignment: .center, spacing: 10) {
            title
            textBody
            buttons
                .padding(.top, 10)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .clipped()
        .padding(.horizontal, 20)
    }

    var title: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            Text("Interaction Detected")
                .font(.title.bold())
        }
    }

    var textBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.dangerousIngestions) { ing in
                getAlertText(for: ing, of: .dangerous)
            }
            ForEach(viewModel.unsafeIngestions) { ing in
                getAlertText(for: ing, of: .unsafe)
            }
            ForEach(viewModel.uncertainIngestions) { ing in
                getAlertText(for: ing, of: .uncertain)
            }
        }
    }

    var buttons: some View {
        HStack {
            Button("Cancel") {
                isShowingAlert.toggle()
            }
            Spacer()
            Button("Add Anyway") {
                isShowingAlert.toggle()
                isShowingNext = true
            }
            .foregroundColor(.red)
        }
    }

    func getAlertText(for ingestion: Ingestion, of type: InteractionType) -> Text {
        var result = Text("")
        switch type {
        case .uncertain:
            result = Text("**Uncertain Interaction**").foregroundColor(.yellow)
        case .unsafe:
            result = Text("**Unsafe Interaction**").foregroundColor(.orange)
        case .dangerous:
            result = Text("**Dangerous Interaction**").foregroundColor(.red)
        case .none:
            break
        }
        // swiftlint:disable shorthand_operator
        result = result + Text(" with **\(ingestion.substanceNameUnwrapped)**")
        let isIngestionInPast = ingestion.timeUnwrapped < Date()
        if isIngestionInPast {
            result = result + Text(" which you took ")
            result = result + Text(ingestion.timeUnwrapped, style: .relative)
            result = result + Text(" ago.")
        } else {
            result = result + Text(" which you planned on taking in ")
            result = result + Text(ingestion.timeUnwrapped, style: .relative)
            result = result + Text(".")
        }
        return result
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

import SwiftUI

struct InteractionAlertView: View {

    @ObservedObject var viewModel: AcknowledgeInteractionsView.ViewModel

    var body: some View {
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
                viewModel.isShowingAlert.toggle()
            }
            Spacer()
            Button("Add Anyway") {
                viewModel.isShowingAlert.toggle()
                viewModel.isShowingNext = true
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

struct InteractionAlertView_Previews: PreviewProvider {
    static var previews: some View {
        InteractionAlertView(viewModel: AcknowledgeInteractionsView.ViewModel())
    }
}

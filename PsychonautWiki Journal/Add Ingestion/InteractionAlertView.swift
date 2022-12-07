import SwiftUI

struct InteractionAlertView: View {

    var alertable: InteractionAlertable

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            title
            textBody
            buttons
                .padding(.top, 10)
        }
        .padding(20)
        .background(.ultraThickMaterial)
        .cornerRadius(15)
        .clipped()
        .padding(.horizontal, 20)
    }

    var iconColor: Color {
        if !alertable.dangerousIngestions.isEmpty {
            return InteractionType.dangerous.color
        } else if !alertable.unsafeIngestions.isEmpty {
            return InteractionType.unsafe.color
        } else {
            return InteractionType.uncertain.color
        }
    }

    var title: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(iconColor)
            Text("Interaction Detected")
                .font(.title.bold())
        }
    }

    var textBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(alertable.dangerousIngestions) { ing in
                getAlertText(for: ing, of: .dangerous)
            }
            ForEach(alertable.unsafeIngestions) { ing in
                getAlertText(for: ing, of: .unsafe)
            }
            ForEach(alertable.uncertainIngestions) { ing in
                getAlertText(for: ing, of: .uncertain)
            }
        }
    }

    var buttons: some View {
        HStack {
            Button("Cancel") {
                alertable.hideAlert()
            }
            Spacer()
            Button("Add Anyway") {
                alertable.hideAlert()
                alertable.showNext()
            }
            .foregroundColor(.red)
        }
    }

    func getAlertText(for ingestion: Ingestion, of type: InteractionType) -> Text {
        var result = Text("")
        switch type {
        case .uncertain:
            result = Text("**Uncertain Interaction**")
        case .unsafe:
            result = Text("**Unsafe Interaction**")
        case .dangerous:
            result = Text("**Dangerous Interaction**")
        }
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
        InteractionAlertView(alertable: AcknowledgeInteractionsView.ViewModel())
    }
}

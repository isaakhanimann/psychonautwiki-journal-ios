import SwiftUI

struct RowLabelView: View {

    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label+" ")
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct RowLabelView_Previews: PreviewProvider {
    static var previews: some View {
        RowLabelView(label: "My label", value: "My Value")
    }
}

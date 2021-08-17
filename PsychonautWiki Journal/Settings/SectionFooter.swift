import SwiftUI

struct SectionFooter: View {

    let label: String

    var body: some View {
        Section(
            footer: HStack {
                Spacer()
                Text(label)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        ) { }
    }
}

struct SectionFooter_Previews: PreviewProvider {
    static var previews: some View {
        SectionFooter(label: "This is on the bottom of a form or list")
    }
}

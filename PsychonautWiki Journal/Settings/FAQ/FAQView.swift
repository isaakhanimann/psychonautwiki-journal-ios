import SwiftUI

struct FAQView: View {

    var body: some View {
        List(QuestionAndAnswer.list) { qAndA in
            DisclosureGroup(qAndA.question) {
                Text(qAndA.answer)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("FAQ")
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FAQView()
    }
}

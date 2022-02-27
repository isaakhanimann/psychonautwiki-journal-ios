import SwiftUI

struct QandAView: View {
    let questionAndAnswer: QuestionAndAnswer
    let isExpanded: Bool

    var body: some View {
        HStack {
            content
            Spacer()
        }
    }

    private var content: some View {
        VStack(alignment: .leading) {
            Text(questionAndAnswer.question).font(.headline)
            if isExpanded {
                Text(questionAndAnswer.answer)
            }
        }
    }
}

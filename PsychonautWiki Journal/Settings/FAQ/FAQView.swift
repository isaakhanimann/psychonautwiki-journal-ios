import SwiftUI

struct FAQView: View {
    @State private var selection: Set<QuestionAndAnswer> = []

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(QuestionAndAnswer.list) { qAndA in
                    QandAView(questionAndAnswer: qAndA, isExpanded: self.selection.contains(qAndA))
                        .onTapGesture { self.selectDeselect(qAndA) }
                        .animation(.linear(duration: 0.3))
                    Divider()
                }
                .padding(.horizontal)
            }
            .navigationTitle("FAQ")
        }
    }

    private func selectDeselect(_ qAndA: QuestionAndAnswer) {
        if selection.contains(qAndA) {
            selection.remove(qAndA)
        } else {
            selection.insert(qAndA)
        }
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FAQView()
    }
}

import Foundation

struct QuestionAndAnswer: Identifiable, Hashable {
    // swiftlint:disable identifier_name
    let id = UUID()
    let question: String
    let answer: String

    // swiftlint:disable line_length
    static let list: [QuestionAndAnswer] = [
        QuestionAndAnswer(
            question: "How is the timeline drawn?",
            answer: "Based on onset, comeup, peak and offset"
        ),
        QuestionAndAnswer(
            question: "How can I change the timeline?",
            answer: "By changing the PsychonautWiki article"
        ),
        QuestionAndAnswer(
            question: "How can I change the dose info?",
            answer: "By changing the PsychonautWiki article"
        ),
        QuestionAndAnswer(
            question: "Why does the timeline not add up the curves for the same substance?",
            answer: "Because its complex"
        ),
        QuestionAndAnswer(
            question: "Why does the timeline not show cumulative effects of different substances?",
            answer: "Because its complex"
        ),
        QuestionAndAnswer(
            question: "Does PsychonautWiki Journal add up the doses of the same substance?",
            answer: "No, it treats every ingestion independently. So make sure that your cumulative dose is not dangerous"
        ),
        QuestionAndAnswer(
            question: "Why would I want to store the experiences in the calendar?",
            answer: "In case anything goes wrong with the app in the future"
        ),
        QuestionAndAnswer(
            question: "How often is the data updated?",
            answer: "Every 2 weeks but you can tap reload in settings if you want to trigger an update"
        ),
        QuestionAndAnswer(
            question: "Why is the eye closed by default?",
            answer: """
    To make sure that only users that have added a substance through one of the links in the PsychonautWiki articles can find the substances they expect.
    People who find the app only through the app store only see a limited set of substances.
    """
        ),
        QuestionAndAnswer(
            question: "How can I open the eye?",
            answer: "By triple tapping it"
        )
    ]
}

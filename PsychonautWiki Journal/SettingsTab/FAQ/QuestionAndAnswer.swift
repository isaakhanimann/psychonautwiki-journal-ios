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
            answer: "The onset duration range from PsychonautWiki defines when the curve starts going up, the comeup how long it goes up for, the peak how long it stays up and the offset how long it takes to come down to baseline. The peak and offset durations are linearly interpolated based on the dose if possible, else it just chooses the middle value of the range. If not all of these durations are defined the timeline for this substance cannot be drawn."
        ),
        QuestionAndAnswer(
            question: "How can one change or add info on a substance (duration, dose, interactions and effects)?",
            answer: "By editing the corresponding PsychonautWiki article."
        ),
        QuestionAndAnswer(
            question: "Why does the timeline not add up the curves for the same substance?",
            answer: "One can not add two curves together because one ingestion might build up tolerance, influencing the curve of the other ingestion. The curve can only be drawn based on data that is available through PsychonautWiki."
        ),
        QuestionAndAnswer(
            question: "Why does the timeline not show cumulative effects of different substances?",
            answer: "Because the curve can only be drawn based on data that is available through PsychonautWiki."
        ),
        QuestionAndAnswer(
            question: "Does PsychonautWiki Journal add up the doses of the same substance?",
            answer: "No, it treats every ingestion independently. So make sure that your cumulative dose is not dangerous"
        ),
        QuestionAndAnswer(
            question: "How often are substances updated?",
            answer: "The app automatically tries to update its substances every 4 days but you can tap refresh in settings if you want it to update immediately."
        ),
        QuestionAndAnswer(
            question: "Why is the eye closed by default?",
            answer: """
    Apple reviewers think that having information on illicit substances in the app by default is encouraging their use. So if users don't opt in they only see a limited set of substances.
    """
        ),
        QuestionAndAnswer(
            question: "How can one open the eye?",
            answer: "By triple tapping it."
        )
    ]
}

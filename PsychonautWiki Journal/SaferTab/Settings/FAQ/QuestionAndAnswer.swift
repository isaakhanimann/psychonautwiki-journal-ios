import Foundation

struct QuestionAndAnswer: Identifiable, Hashable {
    // swiftlint:disable identifier_name
    let id = UUID()
    let question: String
    let answer: String

    static let list: [QuestionAndAnswer] = [
        QuestionAndAnswer(
            question: "Why is an interaction or other info on a substance present in the PsychonautWiki article but not in the app?",
            answer: "There can be a couple reasons. Either the info is not annotated correctly in the article, the PsychonautWiki API does not parse the info correctly or the app does not import the info from the API correctly. In any case please report the bug through the app."
        ),
        QuestionAndAnswer(
            question: "When does the app detect interactions?",
            answer: "If there is an interaction with a substance that was taken less than 2 days ago."
        ),
        QuestionAndAnswer(
            question: "Why are there sometimes more interations in the app than in the PsychonautWiki article?",
            answer: "Because in the PsychonautWiki articles sometimes a substance A lists an interaction with another substance B, but substance B does not list substance A in its interactions. The app consolidates the interactions to always be mutual."
        ),
        QuestionAndAnswer(
            question: "How can one change or add info on a substance (duration, dose, interactions and effects)?",
            answer: "By editing the corresponding PsychonautWiki article."
        ),
        QuestionAndAnswer(
            question: "How long does it take for a change in the PsychonautWiki article to be reflected in the app?",
            answer: "A few days."
        ),
        QuestionAndAnswer(
            question: "How often are substances updated automatically?",
            answer: "The app automatically tries to update its substances every 4 days but one can tap refresh in settings to update them immediately."
        ),
        QuestionAndAnswer(
            question: "How is the timeline drawn?",
            answer: "The onset duration range from PsychonautWiki defines when the curve starts going up, the comeup how long it goes up for, the peak how long it stays up and the offset how long it takes to come down to baseline. The peak and offset durations are linearly interpolated based on the dose if possible, else it just chooses the middle value of the range. If not all of these durations are defined the timeline for this substance cannot be drawn."
        ),
        QuestionAndAnswer(
            question: "Why does it sometimes say \"No Timeline\"?",
            answer: "Because the onset, comeup, peak or offset durations of the substance are not defined for the given administration route."
        ),
        QuestionAndAnswer(
            question: "Why does the timeline not add up the curves for the same substance?",
            answer: "One can not add two curves together because one ingestion might build up tolerance, influencing the curve of the other ingestion. The curve can only be drawn based on data that is available through PsychonautWiki."
        ),
        QuestionAndAnswer(
            question: "Why does the timeline not show cumulative timelines of different substances?",
            answer: "Because the curve can only be drawn based on data that is available through PsychonautWiki."
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

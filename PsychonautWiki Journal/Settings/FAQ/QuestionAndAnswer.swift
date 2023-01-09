import Foundation

struct QuestionAndAnswer: Identifiable, Hashable {
    // swiftlint:disable identifier_name
    let id = UUID()
    let question: String
    let answer: String

    static let list: [QuestionAndAnswer] = [
        QuestionAndAnswer(
            question: "Why is an interaction or other info on a substance present in the PsychonautWiki article but not in the app?",
            answer: "Either the info is not annotated correctly in the article, the PsychonautWiki API does not parse the info correctly or the app does not import the info from the API correctly. In any case please report the bug through the app."
        ),
        QuestionAndAnswer(
            question: "When does the app detect interactions?",
            answer: "If there is an interaction with a substance that was taken less than 2 days ago or there is an interaction with Alcohol, Caffeine, Grapefruit, Hormonal birth control or Nicotine."
        ),
        QuestionAndAnswer(
            question: "How can one change or add info on a substance (duration, dose, interactions and effects)?",
            answer: "By editing the corresponding PsychonautWiki article."
        ),
        QuestionAndAnswer(
            question: "How often are substances updated?",
            answer: "On every new version of the app."
        ),
        QuestionAndAnswer(
            question: "How is the timeline drawn?",
            answer: "The onset duration range from PsychonautWiki defines when the curve starts going up, the comeup how long it goes up for, the peak how long it stays up and the offset how long it takes to come down to baseline. The peak and offset durations are linearly interpolated based on the dose if possible, else it just chooses the middle value of the range. If not all of these durations are defined the timeline for this substance cannot be drawn."
        ),
        QuestionAndAnswer(
            question: "Why does the timeline not add up the curves for the same substance?",
            answer: "One can not add two curves together because one ingestion might build up tolerance, influencing the curve of the other ingestion. The curve can only be drawn based on data that is available through PsychonautWiki."
        ),
        QuestionAndAnswer(
            question: "Why does the timeline not show cumulative timelines of different substances?",
            answer: "Because the curve can only be drawn based on data that is available through PsychonautWiki."
        )
    ]
}

// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import Foundation

struct QuestionAndAnswer: Identifiable, Hashable {
    let id = UUID()
    let question: String
    let answer: String

    static let list: [QuestionAndAnswer] = [
        QuestionAndAnswer(
            question: "Why is an interaction or other info on a substance present in the PsychonautWiki article but not in the app?",
            answer: "Either the info is not annotated correctly in the article, the PsychonautWiki API does not parse the info correctly or the app does not import the info from the API correctly. In any case please report the bug through the app."
        ),
        QuestionAndAnswer(
            question: "When does the app show an interaction warning?",
            answer: "If there is an interaction with a substance that was logged less than 2 days ago or there is an interaction with any of the following: \(InteractionChecker.additionalInteractionsToCheck.joined(separator: ", "))."
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
            answer: "The onset duration range from PsychonautWiki defines when the curve starts going up, the comeup how long it goes up for, the peak how long it stays up and the offset how long it takes to come down to baseline. The peak and offset durations are linearly interpolated based on the dose if possible, else it just chooses the middle value of the range. If some of the durations are missing it draws a dotted line. E.g. if the onset and total time is given it draws a line along the bottom for the onset and then it draws a dotted curve to the end of the total time."
        ),
        QuestionAndAnswer(
            question: "Why does the timeline not cumulate the curves of different ingestions together?",
            answer: "One can not add two curves together because one ingestion might build up tolerance, influencing the curve of the other ingestion. The curve can only be drawn based on data that is available through PsychonautWiki."
        ),
    ]
}

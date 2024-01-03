// Copyright (c) 2023. Isaak Hanimann.
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

enum ShulginRatingOption: String, CaseIterable, Codable, Comparable {
    static func < (lhs: ShulginRatingOption, rhs: ShulginRatingOption) -> Bool {
        lhs.value < rhs.value
    }

    var value: Int {
        switch self {
        case .minus:
            return 0
        case .plusMinus:
            return 1
        case .plus:
            return 2
        case .twoPlus:
            return 3
        case .threePlus:
            return 4
        case .fourPlus:
            return 5
        }
    }

    case minus, plusMinus, plus, twoPlus, threePlus, fourPlus

    var stringRepresentation: String {
        switch self {
        case .minus:
            return "-"
        case .plusMinus:
            return "±"
        case .plus:
            return "+"
        case .twoPlus:
            return "++"
        case .threePlus:
            return "+++"
        case .fourPlus:
            return "++++"
        }
    }

    var description: String {
        switch self {
        case .minus:
            return "On the quantitative potency scale (-, ±, +, ++, +++), there were no effects observed."
        case .plusMinus:
            return "The level of effectiveness of a drug that indicates a threshold action. If a higher dosage produces a greater response, then the plus/minus (±) was valid. If a higher dosage produces nothing, then this was a false positive."
        case .plus:
            return "The drug is quite certainly active. The chronology can be determined with some accuracy, but the nature of the drug's effects are not yet apparent."
        case .twoPlus:
            return "Both the chronology and the nature of the action of a drug are unmistakably apparent. But you still have some choice as to whether you will accept the adventure, or rather just continue with your ordinary day's plans (if you are an experienced researcher, that is). The effects can be allowed a predominant role, or they may be repressible and made secondary to other chosen activities."
        case .threePlus:
            return "Not only are the chronology and the nature of a drug's action quite clear, but ignoring its action is no longer an option. The subject is totally engaged in the experience, for better or worse."
        case .fourPlus:
            return "A rare and precious transcendental state, which has been called a \"peak experience,\" a \"religious experience,\" \"divine transformation,\" a \"state of Samadhi\" and many other names in other cultures. It is not connected to the +1, +2, and +3 of the measuring of a drug's intensity. It is a state of bliss, a participation mystique, a connectedness with both the interior and exterior universes, which has come about after the ingestion of a psychedelic drug, but which is not necessarily repeatable with a subsequent ingestion of that same drug. If a drug (or technique or process) were ever to be discovered which would consistently produce a plus four experience in all human beings, it is conceivable that it would signal the ultimate evolution, and perhaps the end, of the human experiment."
        }
    }

    var shortDescription: String {
        switch self {
        case .minus:
            return "no effects"
        case .plusMinus:
            return "maybe false positive"
        case .plus:
            return "certainly active, nature not yet apparent"
        case .twoPlus:
            return "nature apparent, effects may be repressible"
        case .threePlus:
            return "totally engaged, ignoring no longer an option"
        case .fourPlus:
            return "rare and precious transcendental state"
        }
    }
}

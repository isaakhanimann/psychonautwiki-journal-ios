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

import SwiftUI

struct DosageClassificationScreen: View {
    var body: some View {
        List {
            Section {
                Text(
                    """
                    The range and intensity of the effects of a substance depends on upon a number of factors. These include route of administration, dosage, set and setting, and personal and environmental factors.

                    Effective doses can be divided into five categories: threshold, light, common, strong, and heavy.
                    """)
            }
            Section("Threshold") {
                Text(
                    """
                    A threshold dose is the dose at which the mental and physical alterations produced by the substance first become apparent.
                    These effects are distinctly beyond that of placebo but may still be ignored with some effort by directing one's focus towards the external environment.
                    Subjects may perceive a vague sense of \"something\" or anticipatory energy building up in the background at this level.
                    """)
            }
            Section("Light") {
                Text(
                    """
                    A light dose produces a state which is somewhat distinct from sobriety but does not threaten to override the subject's ordinary awareness.
                    The effects can be ignored by increasing the focus one directs towards the external environment and performing complex tasks.
                    The subject may have to pay particular attention for the substance's effects to be perceptible, or they may be slightly noticeable but will not insist upon the subject's attention.
                    """)
            }
            Section("Common") {
                Text(
                    """
                    A common dose is the dose at which the effects and nature of the substance is quite clear and distinct; the subject's ordinary awareness slips and ignoring its action becomes difficult.
                    The subject will generally be able to partake in regular behaviors and remain functional and able to communicate, although this can depend on the individual.
                    The effects can be allowed to occupy a predominant role or they may be suppressed and made secondary to other chosen activities with sufficient effort or in case of an emergency."
                    """)
            }
            Section("Strong") {
                Text(
                    """
                    A strong dose renders its subject mostly incapable of functioning, interacting normally, or thinking in a straightforward manner.
                    The effects of the substance are clear and can no longer be ignored or suppressed, leaving the subject entirely engaged in the experience regardless of their desire or volition. Negative effects become more common at this level.
                    As subjects are not able to alter the trajectory of their behavior at strong doses, it is vital that they have prepared their environment and activities in advance as well as taken any precautionary measures.
                    """)
            }
            Section("Heavy") {
                Text(
                    """
                    A heavy dose is the upper limit of what a substance is capable of producing in terms of psychoactive effects; doses past this range are associated with rapidly increasing side effects and marginal desirable effects.
                    Depending on the substance consumed, the user may be rendered incapable of functioning and communicating in addition to experiencing extremely uncomfortable side effects that overshadow the positive effects experienced at lower doses.
                    It is absolutely vital to employ harm reduction measures with heavy doses as the user will likely be unable to properly take care of themselves in the event of an emergency. Trip sitters are strongly advised.
                    Users should also be aware that the line between a heavy dose and overdose is often very blurry and they are placing themselves at a significantly higher risk of injury, hospitalization, and death whenever they choose to take a heavy dose.
                    The desire or compulsion to regularly take heavy doses (\"chronic use\") may also be an indicator of tolerance, addiction or other mental health problems.
                    """)
            }
        }
        .navigationTitle("Dosage Classification")
    }
}

#Preview {
    NavigationStack {
        DosageClassificationScreen()
    }
}

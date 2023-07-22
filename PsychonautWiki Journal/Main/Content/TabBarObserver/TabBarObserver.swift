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
import Combine

class TabBarObserver: ObservableObject {

    let tabTapSubject = PassthroughSubject<TabTapOption, Never>() // PassthroughSubject is needed such that onReceive is not executed every time a new subscriber subscribes to it. This happens if the SameTabTapModifier is on a screen that appears.

    var selectedTab: Tab {
        get { _selectedTab }
        set {
            _selectedTab = newValue
            let tapOption = _previousTab == newValue ? TabTapOption.sameTab : TabTapOption.otherTab
            _previousTab = newValue
            tabTapSubject.send(tapOption)
        }
    }

    private var _previousTab: Tab?
    private var _selectedTab: Tab = .journal

    enum TabTapOption {
        case otherTab, sameTab
    }
}

//
//  OptionalScrollDismisser.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 31.12.22.
//

import SwiftUI

struct OptionalScrollDismisser: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollDismissesKeyboard(.immediately)
        } else {
            content
        }
    }
}

extension View {
    func optionalScrollDismissesKeyboard() -> some View {
        modifier(OptionalScrollDismisser())
    }
}

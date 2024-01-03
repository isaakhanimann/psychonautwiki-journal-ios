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

import SwiftUI

struct SubstanceSearchBarWithFilter: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let allCategories: [String]
    let toggleCategory: (String) -> Void
    let selectedCategories: [String]
    let clearCategories: () -> Void

    @Environment(\.colorScheme) var colorScheme
    private let horizontalPadding: CGFloat = 16

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Search substances",
                          text: $text,
                          prompt: Text("Search substances"))
                    .focused(isFocused)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                if !text.isEmpty {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray))
                        .onTapGesture {
                            withAnimation {
                                text = ""
                            }
                        }
                } else {
                    Menu(content: {
                        ForEach(allCategories, id: \.self) { cat in
                            Button {
                                withAnimation {
                                    toggleCategory(cat)
                                }
                            } label: {
                                if selectedCategories.contains(cat) {
                                    Label(cat, systemImage: "checkmark")
                                } else {
                                    Text(cat)
                                }
                            }
                        }
                    }, label: {
                        Label("Filter", systemImage: selectedCategories.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                            .labelStyle(.iconOnly)
                    })
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(backgroundColor)
            .cornerRadius(12)
            .padding(.leading, horizontalPadding)
            .padding(.trailing, isFocused.wrappedValue ? 0 : horizontalPadding)
            if isFocused.wrappedValue {
                Button("Cancel") {
                    withAnimation {
                        text = ""
                        clearCategories()
                        isFocused.wrappedValue = false
                    }
                }.padding(.horizontal, horizontalPadding)
            }
        }
        .animation(.default, value: isFocused.wrappedValue)
    }

    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(.systemGray5)
        } else {
            return Color(.systemGray6)
        }
    }
}

private struct SearchBarContainer: View {
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        SubstanceSearchBarWithFilter(
            text: .constant("d"),
            isFocused: $isSearchFocused,
            allCategories: ["psychedelic", "opioid"],
            toggleCategory: { _ in },
            selectedCategories: [],
            clearCategories: {}
        )
    }
}

#Preview {
    NavigationStack {
        VStack {
            SearchBarContainer()
            Spacer()
        }
        .navigationTitle("Substances")
    }
}

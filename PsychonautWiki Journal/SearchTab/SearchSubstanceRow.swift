//
//  SearchSubstanceRow.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 07.12.22.
//

import SwiftUI
import WrappingHStack

struct SearchSubstanceRow: View {
    let substance: Substance
    let color: Color?

    var body: some View {
        NavigationLink {
            SubstanceView(substance: substance)
        } label: {
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    if let colorUnwrap = color {
                        Image(systemName: "circle.fill")
                            .font(.title2)
                            .foregroundColor(colorUnwrap)
                    }
                    VStack(alignment: .leading) {
                        Text(substance.name).font(.headline)
                        let commonNames = substance.commonNames.joined(separator: ", ")
                        if !commonNames.isEmpty {
                            Text(commonNames).font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                }
                Spacer().frame(height: 5)
                WrappingHStack(
                    substance.categories,
                    id: \.self,
                    alignment: .leading,
                    spacing: .constant(3),
                    lineSpacing: 3
                ) { category in
                    Chip(name: category)
                }
            }
        }

    }
}

struct Chip: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.caption)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(12)
    }
}

struct SearchSubstanceRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SearchSubstanceRow(
                substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                color: nil
            )
        }
    }
}

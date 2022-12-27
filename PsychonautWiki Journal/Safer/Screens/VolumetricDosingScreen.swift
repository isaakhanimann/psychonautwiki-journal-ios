//
//  VolumetricDosingScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 23.12.22.
//

import SwiftUI

struct VolumetricDosingScreen: View {
    var body: some View {
        List {
            Text(
"""
Volumetric dosing is the process of dissolving a compound in a liquid to make it easier to measure. In the interest of harm reduction, it is important to use volumetric dosing with certain compounds that are too potent to measure with traditional weighing scales.
Many psychoactive substances, including benzodiazepines and certain psychedelics, are active at less than a single milligram. Such small quantities cannot be accurately measured with common digital scales, so the substance must instead be dosed volumetrically by weighing out larger amounts of the compound and dissolving it in a calculated volume of a suitable liquid.

Search the internet to determine what solvent to use. All substances should dissolve in alcohol, but many substances will not dissolve in water.
""")
        }.navigationTitle("Volumetric Dosing")
    }
}

struct VolumetricDosingScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VolumetricDosingScreen()
        }
    }
}

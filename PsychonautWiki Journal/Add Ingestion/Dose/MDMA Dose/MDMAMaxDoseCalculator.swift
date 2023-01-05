//
//  MDMAMaxDoseCalculator.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 05.01.23.
//

import SwiftUI

struct MDMAMaxDoseCalculator: View {

    @State private var bodyWeightInKg = 75.0
    @State private var gender = Gender.male
    private var suggestedMaxDoseInMg: Double {
        bodyWeightInKg * gender.mgPerKg
    }
    private var suggestedMaxDoseRounded: Double {
        round(suggestedMaxDoseInMg)
    }
    private var suggestedDoseText: String {
        "\(Int(suggestedMaxDoseRounded)) mg"
    }

    enum Gender {
        case male
        case female

        var mgPerKg: Double {
            switch self {
            case .male:
                return 1.5
            case .female:
                return 1.3
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(suggestedDoseText).font(.title.bold())
            Spacer().frame(height: 15)
            Picker("Gender", selection: $gender) {
                Text("Male").tag(Gender.male)
                Text("Female").tag(Gender.female)
            }.pickerStyle(.segmented)
            Spacer().frame(height: 15)
            Text("\(Int(bodyWeightInKg)) kg").font(.title2.bold())
            Slider(
                value: $bodyWeightInKg,
                in: 40...150,
                step: 5
            ) {
                Text("Body Weight")
            } minimumValueLabel: {
                Text("40")
            } maximumValueLabel: {
                Text("150")
            }
        }
    }
}

struct MDMAMaxRecommendedSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MDMAMaxDoseCalculator()
        }
    }
}

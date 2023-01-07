//
//  ChooseLocationScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 07.01.23.
//

import SwiftUI

struct ChooseLocationScreen: View {

    @ObservedObject var viewModel: FinishIngestionScreen.ViewModel

    var body: some View {
        ChooseLocationScreenContent(locationText: .constant(""))
    }
}

struct ChooseLocationScreenContent: View {

    @Binding var locationText: String

    var body: some View {
        List {
            TextField("Search", text: $locationText, prompt: Text("Enter Location"))
        }
        .navigationTitle("Experience Location")
    }
}

struct ChooseLocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseLocationScreenContent(locationText: .constant(""))
        }
    }
}

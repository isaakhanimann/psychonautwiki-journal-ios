//
//  LockScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 10.01.23.
//

import SwiftUI

struct LockScreen: View {
    var body: some View {
        Image(decorative: "Eye Open")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 130, height: 130, alignment: .center)
    }
}

struct LockScreen_Previews: PreviewProvider {
    static var previews: some View {
        LockScreen()
    }
}

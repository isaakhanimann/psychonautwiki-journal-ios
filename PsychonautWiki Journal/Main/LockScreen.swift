//
//  LockScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 10.01.23.
//

import SwiftUI

struct LockScreen: View {
    var isFaceIDEnabled: Bool
    var body: some View {
        VStack {
            Image(decorative: "Eye Open")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 130, height: 130, alignment: .center)
            if !isFaceIDEnabled {
                Spacer().frame(height: 20)
                Text("Face ID is disabled.\nGo to Settings to enable it for this app.")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
            }
        }
    }
}

struct LockScreen_Previews: PreviewProvider {
    static var previews: some View {
        LockScreen(isFaceIDEnabled: false)
    }
}

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

import CoreImage.CIFilterBuiltins
import SwiftUI

struct ShareScreen: View {
    var body: some View {
        List {
            Section("iOS and Android") {
                let link = "https://psychonautwiki.org/wiki/PsychonautWiki_Journal"
                QRCodeView(url: link)
                ShareLink("Share link", item: URL(string: link)!)
                Link(destination: URL(string: link)!) {
                    Label("Open link", systemImage: "safari")
                }
            }
            Section("iOS App") {
                HStack {
                    Text("After download triple tap the closed eye in settings to unlock all substances.")
                    Spacer()
                    Image("Eye Closed")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
                let appStoreLink = "https://apps.apple.com/ch/app/psychonautwiki-journal/id1582059415"
                QRCodeView(url: appStoreLink)
                ShareLink("Share app store link", item: URL(string: appStoreLink)!)
                Link(destination: URL(string: appStoreLink)!) {
                    Label("Open app store link", systemImage: "safari")
                }
            }
            Section("Android App") {
                let playStoreLink = "https://play.google.com/store/apps/details?id=com.isaakhanimann.journal"
                QRCodeView(url: playStoreLink)
                ShareLink("Share play store link", item: URL(string: playStoreLink)!)
                Link(destination: URL(string: playStoreLink)!) {
                    Label("Open play store link", systemImage: "safari")
                }
            }
        }
        .navigationTitle("Share App")
    }
}

#Preview {
    NavigationStack {
        ShareScreen()
    }
}

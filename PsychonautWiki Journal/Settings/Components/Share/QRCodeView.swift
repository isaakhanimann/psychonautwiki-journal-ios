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

struct QRCodeView: View {
    var url: String

    var body: some View {
        if let qrCode = generateQRCode(from: url) {
            Image(uiImage: convertCIImageToUIImage(ciImage: qrCode))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Text("Generating QR Code failed.")
        }
    }

    private func generateQRCode(from string: String) -> CIImage? {
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        if let output = filter.outputImage?.transformed(by: transform) {
            return output
        }
        return nil
    }

    private func convertCIImageToUIImage(ciImage: CIImage) -> UIImage {
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    QRCodeView(url: "hello")
}

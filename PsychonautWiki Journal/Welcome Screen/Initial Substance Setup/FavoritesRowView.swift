import SwiftUI

struct FavoritesRowView: View {

    @ObservedObject var substance: Substance

    var body: some View {
        HStack {
            Text(substance.nameUnwrapped)
            Spacer()
            Button {
                substance.isFavorite.toggle()
            } label: {
                if substance.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: "star")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }
            }
            .fixedSize()
        }
    }
}

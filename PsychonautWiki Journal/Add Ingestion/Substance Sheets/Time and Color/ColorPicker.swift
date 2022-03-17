import SwiftUI

struct ColorPicker: View {

    @Binding var selectedColor: IngestionColor

    var body: some View {
        LazyVGrid(columns: colorColumns) {
            ForEach(IngestionColor.allCases, content: colorButton)
        }
        .padding(.vertical)
    }

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    private func colorButton(for color: IngestionColor) -> some View {
        ZStack {
            color.swiftUIColor
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)
            if color == selectedColor {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            selectedColor = color
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            color == selectedColor
            ? [.isButton, .isSelected]
            : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(color.rawValue))
    }
}

struct ColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        ColorPicker(selectedColor: .constant(.blue))
    }
}

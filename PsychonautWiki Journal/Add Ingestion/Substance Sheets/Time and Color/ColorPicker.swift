import SwiftUI

struct ColorPicker: View {

    @Binding var selectedColor: SubstanceColor
    let alreadyUsedColors: Set<SubstanceColor>
    let otherColors: Set<SubstanceColor>

    var body: some View {
        VStack(alignment: .leading) {
            Text("Free Colors")
            LazyVGrid(columns: colorColumns) {
                ForEach(Array(otherColors), content: colorButton)
            }
            Text("Already Used Colors")
            LazyVGrid(columns: colorColumns) {
                ForEach(Array(alreadyUsedColors), content: colorButton)
            }
        }
        .padding(.vertical)
    }

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    private func colorButton(for color: SubstanceColor) -> some View {
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
        NavigationView {
            Form {
                Section {
                    let alreadyUsed: Set = [SubstanceColor.blue, .red, .orange]
                    ColorPicker(
                        selectedColor: .constant(.blue),
                        alreadyUsedColors: alreadyUsed,
                        otherColors: Set(SubstanceColor.allCases).subtracting(alreadyUsed)
                    )
                }
            }
        }
    }
}

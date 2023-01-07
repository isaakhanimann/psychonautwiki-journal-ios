import SwiftUI

struct ColorPickerScreen: View {

    @Binding var selectedColor: SubstanceColor
    let alreadyUsedColors: Set<SubstanceColor>
    let otherColors: Set<SubstanceColor>
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            if !alreadyUsedColors.isEmpty {
                Section("Free Colors") {
                    ForEach(Array(otherColors)) { color in
                        button(for: color)
                    }
                }.headerProminence(.increased)
            }
            if !alreadyUsedColors.isEmpty {
                Section("Used Colors") {
                    ForEach(Array(alreadyUsedColors)) { color in
                        button(for: color)
                    }
                }.headerProminence(.increased)
            }
        }.navigationTitle("Choose Color")
    }

    private func button(for color: SubstanceColor) -> some View {
        Button {
            selectedColor = color
            dismiss()
        } label: {
            if selectedColor == color {
                HStack {
                    Label(color.rawValue, systemImage: "circle.fill").foregroundColor(color.swiftUIColor)
                    Spacer()
                    Image(systemName: "checkmark")
                }
            } else {
                Label(color.rawValue, systemImage: "circle.fill").foregroundColor(color.swiftUIColor)
            }
        }

    }
}

struct ColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let alreadyUsed: Set = [SubstanceColor.blue, .red, .orange]
            ColorPickerScreen(
                selectedColor: .constant(.purple),
                alreadyUsedColors: alreadyUsed,
                otherColors: Set(SubstanceColor.allCases).subtracting(alreadyUsed)
            )
        }
    }
}

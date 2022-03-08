import SwiftUI

struct ChooseTimeAndColor: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dose: Double
    let dismiss: () -> Void
    let experience: Experience?
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Time")) {
                    DatePicker("Time", selection: $viewModel.selectedTime, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                }
                Section(header: Text("Color")) {
                    LazyVGrid(columns: colorColumns) {
                        ForEach(Ingestion.IngestionColor.allCases, id: \.self, content: colorButton)
                    }
                    .padding(.vertical)
                }
            }
            if let experienceUnwrap = experience {
                Button("Add Ingestion") {
                    viewModel.addIngestionSaveAndDismiss(to: experienceUnwrap)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            } else {
                if let lastExperienceUnwrap = viewModel.lastExperience {
                    Button("Add to \(lastExperienceUnwrap.titleUnwrapped)") {
                        viewModel.addIngestionSaveAndDismiss(to: lastExperienceUnwrap)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                }
                Button("Add to new experience") {
                    viewModel.addIngestionToNewExperienceSaveAndDismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            }
        }
        .task {
            viewModel.initialize(
                substance: substance,
                administrationRoute: administrationRoute,
                dose: dose,
                dismiss: dismiss,
                experience: experience
            )
        }
        .navigationBarTitle("Choose Time")
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                Button("Cancel", action: dismiss)
            }
        }
    }

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    private func colorButton(for color: Ingestion.IngestionColor) -> some View {
        ZStack {
            Color.from(ingestionColor: color)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)

            if color == viewModel.selectedColor {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            viewModel.selectedColor = color
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            color == viewModel.selectedColor
            ? [.isButton, .isSelected]
            : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(color.rawValue))
    }
}

struct ChooseTimeAndColor_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        return ChooseTimeAndColor(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dose: 10,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}

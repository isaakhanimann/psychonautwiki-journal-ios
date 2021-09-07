import SwiftUI

struct ChooseRouteView: View {

    let substance: Substance
    let dismiss: () -> Void
    let experience: Experience

    var body: some View {
        List {
            ForEach(substance.administrationRoutesUnwrapped, id: \.self) { route in
                NavigationLink(
                    route.displayString,
                    destination: ChooseDoseView(
                        substance: substance,
                        administrationRoute: route,
                        dismiss: dismiss,
                        experience: experience
                    )
                )
            }
        }
        .navigationBarTitle("Choose Route")
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                Button("Cancel", action: dismiss)
            }
        }
    }
}

struct ChooseRouteView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseRouteView(
            substance: helper.substance,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}
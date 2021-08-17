import SwiftUI

struct EditRoaView: View {

    @ObservedObject var roa: Roa

    @Environment(\.managedObjectContext) var moc

    @State private var name: Roa.AdministrationRoute

    init(roa: Roa) {
        self.roa = roa
        self._name = State(wrappedValue: roa.nameUnwrapped)
    }

    var body: some View {
        Form {
            Picker("Route", selection: $name) {
                ForEach(Roa.AdministrationRoute.allCases, id: \.rawValue) { route in
                    Text(route.displayString).tag(route)
                }
            }
            .onChange(of: name) { _ in update() }

            Section {
                NavigationLink(
                    "Dose Info",
                    destination: EditDosesView(doseTypes: roa.doseTypes!)
                )
            }

            Section {
                NavigationLink(
                    "Duration Info",
                    destination: EditDurationsView(durationTypes: roa.durationTypes!)
                )
            }
        }
        .navigationTitle("Edit Route")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear(perform: {
            if moc.hasChanges {
                try? moc.save()
            }
        })
    }

    func update() {
        roa.objectWillChange.send()
        roa.name = name.rawValue
    }

}

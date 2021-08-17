import SwiftUI

struct EditSubstanceView: View {

    @ObservedObject var substance: Substance

    @Environment(\.managedObjectContext) var moc

    @State private var name: String
    @State private var url: String
    @State private var isFavorite: Bool
    @State private var isShowingSheet = false
    @State private var isKeyboardShowing = false

    init(substance: Substance) {
        self.substance = substance
        self._name = State(wrappedValue: substance.nameUnwrapped)
        self._url = State(wrappedValue: substance.url?.absoluteString ?? "")
        self._isFavorite = State(wrappedValue: substance.isFavorite)
    }

    var body: some View {
        Form {
            TextField("Enter Name", text: $name)
            TextField("e.g. https://www.apple.com", text: $url)
                .keyboardType(.webSearch)
                .autocapitalization(.none)
            Toggle("Favorite", isOn: $isFavorite)

            Section(header: roasSectionHeader) {
                ForEach(substance.roasUnwrapped) { roa in
                    NavigationLink(
                        roa.nameUnwrapped.displayString,
                        destination: EditRoaView(roa: roa)
                    )
                    .deleteDisabled(substance.roasUnwrapped.count == 1)
                }
                .onDelete(perform: deleteRoa)
            }

            if !substance.category!.file!.generalInteractionsUnwrapped.isEmpty
                || !substance.category!.file!.categoriesUnwrapped.isEmpty
                || !substance.category!.file!.allSubstancesUnwrapped.isEmpty {
                NavigationLink(
                    destination: UnsafeInteractionsView(substance: substance)
                ) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Unsafe Interactions")
                    }
                }
                NavigationLink(
                    destination: DangerousInteractionsView(substance: substance)
                ) {
                    HStack {
                        Image(systemName: "exclamationmark.3")
                        Text("Dangerous Interactions")
                    }
                }
            }
        }
        .onChange(of: name) { _ in update() }
        .onChange(of: url) { _ in update() }
        .onChange(of: isFavorite) { _ in update() }
        .sheet(isPresented: $isShowingSheet) {
            AddRoaView(substance: substance)
                .environment(\.managedObjectContext, self.moc)
                .accentColor(Color.orange)
        }
        .navigationTitle("Edit Substance")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear(perform: {
            if moc.hasChanges {
                try? moc.save()
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation {
                isKeyboardShowing = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation {
                isKeyboardShowing = false
            }
        }
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                if isKeyboardShowing {
                    Button {
                        hideKeyboard()
                        if moc.hasChanges {
                            try? moc.save()
                        }
                    } label: {
                        Text("Done")
                            .font(.callout)
                    }
                }
            }
        }
    }

    private func deleteRoa(at offsets: IndexSet) {
        for offset in offsets {
            let roa = substance.roasUnwrapped[offset]
            moc.delete(roa)
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }

    private func update() {
        substance.category?.objectWillChange.send()
        substance.name = name
        substance.url = URL(string: url)
        substance.isFavorite = isFavorite
    }

    private var roasSectionHeader: some View {
        HStack {
            Text("Administration Routes")
            Spacer()
            Button(
                action: {
                    self.isShowingSheet.toggle()
                },
                label: {
                    Label("Add Administration Route", systemImage: "plus")
                        .labelStyle(IconOnlyLabelStyle())
                }
            )
        }
    }
}

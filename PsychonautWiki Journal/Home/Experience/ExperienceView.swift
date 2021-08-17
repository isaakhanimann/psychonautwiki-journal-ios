import SwiftUI

struct ExperienceView: View {

    @ObservedObject var experience: Experience

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var calendarWrapper: CalendarWrapper

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isSelected == true")
    ) var selectedFile: FetchedResults<SubstancesFile>

    @State private var selectedTitle: String
    @State private var isShowingAddIngestionSheet = false
    @State private var writtenText: String
    @State private var isKeyboardShowing = false
    @State private var isShowingEmptyFileAlert = false

    var body: some View {
        List {
            Section(header: Text("Title")) {
                TextField("Title", text: $selectedTitle)
            }
            Section(header: ingestionHeader) {
                ForEach(experience.sortedIngestionsUnwrapped, content: IngestionRow.init)
                    .onDelete(perform: deleteIngestions)

                if experience.sortedIngestionsUnwrapped.isEmpty {
                    Button(action: addIngestion) {
                        Label("Add Ingestion", systemImage: "plus")
                            .foregroundColor(.accentColor)
                    }
                }
            }

            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section(header: Text("Timeline")) {
                    LineChartWithPicker(sortedIngestions: experience.sortedIngestionsUnwrapped)
                        .padding(.bottom, 10)
                        .listRowInsets(EdgeInsets())
                }
            }

            Section(header: Text("Notes")) {
                ZStack {
                    TextEditor(text: $writtenText)
                        .frame(minHeight: 200, alignment: .leading)
                        .foregroundColor(self.writtenText == placeholderString ? .gray : .primary)
                        .onTapGesture {
                            if self.writtenText == placeholderString {
                                self.writtenText = ""
                            }
                        }
                    Text(writtenText).opacity(0).padding(.all, 8)
                }

            }
        }
        .navigationTitle(selectedTitle)
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                if isKeyboardShowing {
                    Button {
                        hideKeyboard()
                        save()
                    } label: {
                        Text("Done")
                            .font(.callout)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation {
                isKeyboardShowing = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation {
                isKeyboardShowing = false
                if writtenText == "" {
                    writtenText = placeholderString
                }
            }
        }
        .onChange(of: selectedTitle) { _ in update() }
        .onChange(of: writtenText) { _ in update() }
        .onDisappear(perform: save)
        .sheet(isPresented: $isShowingAddIngestionSheet) {
            ChooseSubstanceView(substancesFile: selectedFile.first!, dismiss: {isShowingAddIngestionSheet.toggle()})
                .environment(\.managedObjectContext, self.moc)
                .environmentObject(experience)
                .environmentObject(calendarWrapper)
                .accentColor(Color.orange)
        }
        .alert(isPresented: $isShowingEmptyFileAlert) {
            Alert(
                title: Text("No Substances"),
                message: Text(
                    """
                    \(selectedFile.first!.filenameUnwrapped) has no substances. \
                    Add substances or pick different definitions in Settings to add ingestions.
                    """),
                dismissButton: .default(Text("Ok"))
            )
        }
    }

    private func addIngestion() {
        if selectedFile.first!.allSubstancesUnwrapped.isEmpty {
            isShowingEmptyFileAlert.toggle()
        } else {
            isShowingAddIngestionSheet.toggle()
        }
    }

    init(experience: Experience) {
        self.experience = experience
        _selectedTitle = State(wrappedValue: experience.titleUnwrapped)
        let initialText = experience.textUnwrapped
        _writtenText = State(wrappedValue: initialText == "" ? placeholderString : initialText)
    }

    private let placeholderString = "Enter some notes here"

    private func deleteIngestions(at offsets: IndexSet) {
        for offset in offsets {
            let ingestion = experience.sortedIngestionsUnwrapped[offset]
            moc.delete(ingestion)
        }
        save()
    }

    var ingestionHeader: some View {
        HStack {
            Text("Ingestions")
            Spacer()
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Button(action: addIngestion) {
                    Label("Add Ingestion", systemImage: "plus")
                        .labelStyle(IconOnlyLabelStyle())
                }
            }
        }
    }

    private func save() {
        if moc.hasChanges {
            calendarWrapper.createOrUpdateEventBeforeMocSave(from: experience)
            do {
                try moc.save()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    private func update() {
        experience.objectWillChange.send()
        experience.title = selectedTitle
        if writtenText != placeholderString {
            experience.text = writtenText
        }
    }
}

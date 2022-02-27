import SwiftUI

struct ExperienceView: View {

    @ObservedObject var experience: Experience

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var calendarWrapper: CalendarWrapper

    @State private var selectedTitle: String
    @State private var isShowingAddIngestionSheet = false
    @State private var writtenText: String
    @State private var isKeyboardShowing = false

    var body: some View {
        List {
            Section(header: Text("Title")) {
                TextField("Title", text: $selectedTitle)
            }
            Section(header: Text("Ingestions")) {
                ForEach(experience.sortedIngestionsUnwrapped, content: IngestionRow.init)
                    .onDelete(perform: deleteIngestions)

                Button(action: showOrHideAddIngestionSheet) {
                    Label("Add Ingestion", systemImage: "plus")
                        .foregroundColor(.accentColor)
                }
            }

            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section(
                    header: Text("Timeline"),
                    footer: Text("Source: PsychonautWiki onset, comeup, peak & offset")
                ) {
                    HorizontalScaleView {
                        IngestionTimeLineView(sortedIngestions: experience.sortedIngestionsUnwrapped)
                    }
                    .frame(height: 310)
                }
            }

            Section(header: Text("Notes")) {
                ZStack {
                    TextEditor(text: $writtenText)
                        .frame(minHeight: 200, alignment: .leading)
                        .foregroundColor(self.writtenText == placeholderString ? .secondary : .primary)
                        .onTapGesture {
                            if self.writtenText == placeholderString {
                                self.writtenText = ""
                            }
                        }
                    Text(writtenText).opacity(0).padding(.all, 8)
                }

            }

            if Connectivity.shared.isPaired && !Connectivity.shared.isComplicationEnabled {
                NavigationLink(destination: AddFaceView()) {
                    Label("Add Watch Face", systemImage: "applewatch.watchface")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
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
            ChooseSubstanceView(
                dismiss: showOrHideAddIngestionSheet,
                experience: experience
            )
                .environment(\.managedObjectContext, self.moc)
                .environmentObject(calendarWrapper)
                .accentColor(Color.blue)
        }
    }

    private func showOrHideAddIngestionSheet() {
        isShowingAddIngestionSheet.toggle()
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

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ExperienceView(experience: helper.experiences.first!)
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
            .environmentObject(Connectivity())
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}

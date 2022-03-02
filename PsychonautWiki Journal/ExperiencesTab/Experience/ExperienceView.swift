import SwiftUI

struct ExperienceView: View {

    @ObservedObject var experience: Experience
    @EnvironmentObject var calendarWrapper: CalendarWrapper
    @State private var selectedTitle: String
    @State private var isShowingAddIngestionSheet = false
    @State private var writtenText: String

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
        .onChange(of: selectedTitle) { _ in update() }
        .onChange(of: writtenText) { _ in update() }
        .sheet(isPresented: $isShowingAddIngestionSheet) {
            ChooseSubstanceView(
                dismiss: showOrHideAddIngestionSheet,
                experience: experience
            )
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
            PersistenceController.shared.viewContext.delete(ingestion)
        }
        PersistenceController.shared.saveViewContext()
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
        ExperienceView(experience: PreviewHelper.shared.experiences.first!)
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}

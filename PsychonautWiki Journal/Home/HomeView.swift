import SwiftUI

struct HomeView: View {

    let toggleSettingsVisibility: () -> Void

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var calendarWrapper: CalendarWrapper

    @FetchRequest(
        entity: Experience.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
    ) var experiences: FetchedResults<Experience>

    private var experiencesSorted: [Experience] {
        experiences.sorted { experience1, experience2 in
            experience1.dateToSortBy > experience2.dateToSortBy
        }
    }

    @State private var selection: Experience?
    @State private var isShowingDeleteExperienceAlert = false
    @State private var offsets: IndexSet?

    var body: some View {
        NavigationView {
            List {
                ForEach(experiencesSorted) { experience in
                    ExperienceRow(experience: experience, timer: timer, selection: $selection)
                        .padding(.vertical)
                }
                .onDelete(perform: deleteExperiencesMaybe)
                .alert(isPresented: $isShowingDeleteExperienceAlert) {
                    deleteExperienceAlert
                }

                if experiences.isEmpty {
                    addExperienceButton
                        .padding(.vertical)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Experiences")
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button(
                        action: toggleSettingsVisibility,
                        label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    )
                }
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    if !experiences.isEmpty {
                        addExperienceButton
                    }
                }
            }
        }
        .currentDeviceNavigationViewStyle()
    }

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var deleteExperienceAlert: Alert {
        Alert(
            title: Text("Are you sure?"),
            message: Text("There is no undo"),
            primaryButton: .destructive(Text("Delete")) {
                deleteExperiences()
            },
            secondaryButton: .cancel()
        )
    }

    private var addExperienceButton: some View {
        Button {
            withAnimation {
                let experience = Experience(context: moc)
                let now = Date()
                experience.creationDate = now
                experience.title = now.asDateString
                calendarWrapper.createOrUpdateEventBeforeMocSave(from: experience)
                try? moc.save()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    selection = experience
                }
            }
        } label: {
            Label("Add Experience", systemImage: "plus")
        }
    }

    private func deleteExperiencesMaybe(at offsets: IndexSet) {
        self.offsets = offsets
        self.isShowingDeleteExperienceAlert.toggle()
    }

    private func deleteExperiences() {
        for offset in self.offsets! {
            let experience = experiencesSorted[offset]
            moc.delete(experience)
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(toggleSettingsVisibility: {})
    }
}

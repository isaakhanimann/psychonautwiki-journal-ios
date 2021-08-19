import SwiftUI

struct HomeView: View {

    let toggleSettingsVisibility: () -> Void

    #if DEBUG
    let isDoingAppStoreScreenshots = false
    #endif

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var calendarWrapper: CalendarWrapper

    @FetchRequest(
        entity: Experience.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
    ) var experiences: FetchedResults<Experience>

    #if DEBUG
    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>
    #endif

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
            ZStack(alignment: .bottom) {
                List {
                    ForEach(experiencesSorted) { experience in
                        ExperienceRow(experience: experience, timer: timer, selection: $selection)
                    }
                    .onDelete(perform: deleteExperiencesMaybe)
                    .alert(isPresented: $isShowingDeleteExperienceAlert) {
                        deleteExperienceAlert
                    }

                }
                .listStyle(InsetGroupedListStyle())

                if experiences.isEmpty {
                    Button(action: {
                        #if DEBUG
                        if isDoingAppStoreScreenshots {
                            _ = PreviewHelper.createDefaultExperiences(
                                context: moc,
                                substancesFile: storedFile.first!
                            )
                            try? moc.save()
                        } else {
                            addExperience()
                        }
                        #else
                        addExperience()
                        #endif
                    }, label: {
                        Label("Add Experience", systemImage: "plus")

                    })
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                }
            }
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
                        Button(action: addExperience) {
                            Label("Add Experience", systemImage: "plus")
                        }
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

    private func addExperience() {
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

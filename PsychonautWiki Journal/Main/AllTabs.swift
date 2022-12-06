import SwiftUI

struct AllTabs: View {

    @State private var tabSelection = TabSelection.substances
    @State private var tappedTwice: Bool = false
    @State private var experienceID = UUID()
    @State private var ingestionID = UUID()
    @State private var searchID = UUID()
    @State private var settingsID = UUID()

    enum TabSelection {
        case experience, ingestions, substances, settings
    }

    var body: some View {
        var handler: Binding<TabSelection> {
            Binding {
                self.tabSelection
            } set: {
                if $0 == self.tabSelection {
                    tappedTwice = true
                }
                self.tabSelection = $0
            }
        }
        return TabView(selection: handler) {
            ExperiencesTab()
                .id(experienceID)
                .tag(TabSelection.experience)
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Experiences")
                }
            StatsTab()
                .id(ingestionID)
                .tag(TabSelection.ingestions)
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Stats")
                }
            SearchTab()
                .id(searchID)
                .tag(TabSelection.substances)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Substances")
                }
            SettingsTab()
                .id(settingsID)
                .tag(TabSelection.settings)
                .tabItem {
                    Image(systemName: "cross.fill")
                    Text("Safer")
                }
        }
        .onChange(
            of: tappedTwice,
            perform: { newValue in
                guard newValue else {return}
                switch tabSelection {
                case .experience:
                    reloadExperienceTab()
                case .ingestions:
                    reloadIngestionTab()
                case .substances:
                    reloadSearchTab()
                case .settings:
                    reloadSettingsTab()
                }
                tappedTwice = false
            }
        )
    }

    private func reloadExperienceTab() {
        experienceID = UUID()
    }

    private func reloadIngestionTab() {
        ingestionID = UUID()
    }

    private func reloadSearchTab() {
        searchID = UUID()
    }

    private func reloadSettingsTab() {
        settingsID = UUID()
    }
}

struct AllTabs_Previews: PreviewProvider {
    static var previews: some View {
        AllTabs()
    }
}

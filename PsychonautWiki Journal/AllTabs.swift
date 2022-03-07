import SwiftUI

struct AllTabs: View {

    @State private var tabSelection = TabSelection.experience
    @State private var tappedTwice: Bool = false
    @State private var experienceID = UUID()
    @State private var searchID = UUID()
    @State private var settingsID = UUID()

    enum TabSelection {
        case experience, search, settings
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
                    Text("Your Experiences")
                }
            SearchTab()
                .id(searchID)
                .tag(TabSelection.search)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            SettingsTab()
                .id(settingsID)
                .tag(TabSelection.settings)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .onChange(
            of: tappedTwice,
            perform: { newValue in
                guard newValue else {return}
                switch tabSelection {
                case .experience:
                    reloadExperienceTab()
                case .search:
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

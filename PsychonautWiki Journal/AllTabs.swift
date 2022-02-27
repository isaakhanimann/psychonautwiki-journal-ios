import SwiftUI

struct AllTabs: View {

    var body: some View {
        TabView {
            ExperiencesTab()
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Your Experiences")
                }
            SearchTab()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            SettingsTab()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}

struct AllTabs_Previews: PreviewProvider {
    static var previews: some View {
        AllTabs()
    }
}

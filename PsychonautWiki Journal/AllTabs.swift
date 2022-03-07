import SwiftUI

struct AllTabs: View {

    @State private var tabSelection = 0
    @State private var tappedTwice: Bool = false
    @State private var search = UUID()
    @State private var experience = UUID()

    var body: some View {
        var handler: Binding<Int> {
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
                .id(experience)
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Your Experiences")
                }
                .tag(0)
            SearchTab()
                .id(search)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            SettingsTab()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .onChange(of: tappedTwice, perform: { newValue in
            guard newValue else {return}
            if tabSelection == 0 {
                experience = UUID()
            } else if tabSelection == 1 {
                search = UUID()
            }
            tappedTwice = false
        })
    }
}

struct AllTabs_Previews: PreviewProvider {
    static var previews: some View {
        AllTabs()
    }
}

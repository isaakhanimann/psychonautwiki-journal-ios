import SwiftUI

struct EmptySectionForPadding: View {
    var body: some View {
        Section(header: Text("")) {
            EmptyView()
        }
    }
}

struct EmptySectionForPadding_Previews: PreviewProvider {
    static var previews: some View {
        EmptySectionForPadding()
    }
}

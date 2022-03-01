import SwiftUI

struct PsychoactiveView: View {

    let psychoactive: PsychoactiveClass

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PsychoactiveView_Previews: PreviewProvider {
    static var previews: some View {
        PsychoactiveView(psychoactive: PreviewHelper.shared.substancesFile.psychoactiveClassesSorted.first!)
    }
}

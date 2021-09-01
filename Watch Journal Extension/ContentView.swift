import SwiftUI

struct ContentView: View {

    @EnvironmentObject var connectivity: Connectivity

    var body: some View {
        VStack {
            Text(connectivity.receivedText)
            Button("Send UserInfo", action: sendUserInfo)
        }
    }

    func sendUserInfo() {
        let data = ["text": "Hello from the watch"]
        connectivity.transferUserInfo(data)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

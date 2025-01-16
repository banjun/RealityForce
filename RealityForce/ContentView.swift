import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")

            ToggleImmersiveSpaceButton()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}

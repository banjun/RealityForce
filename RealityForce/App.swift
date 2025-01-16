import SwiftUI

@main
struct App: SwiftUI.App {
    @State private var appModel = AppModel()
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .task {
                    appModel.immersiveSpaceState = .inTransition
                    await openImmersiveSpace(id: appModel.immersiveSpaceID)
                }
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: $appModel.immersionStyle, in: .progressive, .mixed)
    }
}

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var immersionStyle: ImmersionStyle = MixedImmersionStyle() // ProgressiveImmersionStyle(immersion: 0...1, initialAmount: 1)
}

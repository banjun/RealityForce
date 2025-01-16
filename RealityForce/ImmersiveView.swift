import SwiftUI
import RealityKit

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            content.add(try! await Entity(named: "SkyDome"))

            let hand = AnchorEntity(.hand(.left, location: .joint(for: .indexFingerIntermediateBase)), trackingMode: .predicted)
            let compass = CompassEntity()
            compass.transform = .init(rotation: .init(angle: .pi / 2, axis: .init(1, 0, 0)), translation: .init(0, 0, 0.02))
            hand.addChild(compass)
            content.add(hand)
            // hand.addChild(Entity(axesWithLength: 0.01))
        }
        .upperLimbVisibility(.hidden)
        .onAppear {MagneticForceSystem.registerSystem()}
        .task {await spatialTrackingSession.run(.init(tracking: [.hand]))} // for transform conversion between the hand anchor space and the immersive space
    }

    private let spatialTrackingSession: SpatialTrackingSession = .init()
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}

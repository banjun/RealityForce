import RealityKit

final class CompassEntity: Entity {
    required init() {
        super.init()
        components.set(PhysicsSimulationComponent())
        components.set(MagneticForceReceiverComponent())

        let disc = ModelEntity(mesh: .generateCylinder(height: 0.001, radius: 0.03), materials: [SimpleMaterial(color: .gray, isMetallic: false)])
        let marker = ModelEntity(mesh: .generateBox(width: 0.001, height: 0.00003, depth: 0.01), materials: [SimpleMaterial(color: .white, isMetallic: true)])
        marker.position = .init(0, 0.001 / 2 + 0.001 / 2, -0.03 + 0.01 / 2)
        disc.addChild(marker)
        addChild(disc)

        let n = ModelEntity(mesh: .generateCone(height: 0.02, radius: 0.003), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        let s = ModelEntity(mesh: .generateCone(height: 0.02, radius: 0.003), materials: [SimpleMaterial(color: .white, isMetallic: false)])
        n.scale.z = 0.1
        s.transform = .init(scale: .init(1, 1, 0.1), rotation: .init(angle: .pi, axis: .init(1, 0, 0)), translation: .init(0, -0.02, 0))
        n.addChild(s)
        addChild(n)

        n.components.set({
            var p = PhysicsBodyComponent(massProperties: .init(mass: 0.001, centerOfMass: (position: .init(0, 0.02, 0), orientation: .init(.identity))), mode: .dynamic)
            p.isAffectedByGravity = false
            p.angularDamping = 1
            p.material = .generate(friction: 0, restitution: 0)
            return p
        }())
        n.generateCollisionShapes(recursive: false)

        disc.components.set(PhysicsBodyComponent(mode: .static))
        disc.generateCollisionShapes(recursive: false)

        // x-axis is free in PhysicsRevoluteJoint by default.
        // for nPin, free rotation should be around thin direction (z-axis)
        // for discPin, free rotation should be around face direction (y-axis)
        func revoluteAround(axis: SIMD3<Float>) -> simd_quatf { .init(from: SIMD3<Float>(1, 0, 0), to: axis) }
        let nPin = n.pins.set(named: "nFoot", position: .init(0, -0.01, 0), orientation: revoluteAround(axis: .init(0, 0, 1)))
        let discPin = disc.pins.set(named: "discCenter", position: .init(0, 0.005, 0), orientation: revoluteAround(axis: .init(0, 1, 0)))
        try! PhysicsRevoluteJoint(pin0: discPin, pin1: nPin).addToSimulation()
    }
}

struct MagneticForceReceiverComponent: Component {}
/// visionOS doesn't provide real magnetic sensor values. fake by immersive space (0, 0, -1)
/// Since ConstantForceEffect cannot be set using immersive space vector, we should convert transform by the System
struct MagneticForceSystem: System {
    static let query = EntityQuery(where: .has(MagneticForceReceiverComponent.self))
    static var fakeNorth: SIMD3<Float> = .init(0, 0, -1)
    init(scene: RealityKit.Scene) {}
    func update(context: SceneUpdateContext) {
        context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { e in
            let direction: SIMD3<Float> = e.convert(direction: Self.fakeNorth, from: nil)
            // NSLog("%@", "direction = \(direction)")
            e.components.set(ForceEffectComponent(effect: ForceEffect(effect: ConstantForceEffect(strength: 100, direction: direction))))
        }
    }
}

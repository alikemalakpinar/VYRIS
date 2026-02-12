import CoreMotion
import SwiftUI
import Combine

// MARK: - Motion Manager
// Provides subtle device tilt data for card parallax effect.
// Max 5° rotation with smooth interpolation.

@Observable
final class MotionManager {

    var pitch: Double = 0
    var roll: Double = 0

    var isActive: Bool = false

    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private let maxDegrees: Double = 5
    private let smoothingFactor: Double = 0.15

    private var targetPitch: Double = 0
    private var targetRoll: Double = 0

    init() {
        queue.name = "com.vyris.motion"
        queue.maxConcurrentOperationCount = 1
    }

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        isActive = true

        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: queue
        ) { [weak self] motion, _ in
            guard let self, let motion else { return }

            let pitchDegrees = motion.attitude.pitch * (180.0 / .pi)
            let rollDegrees = motion.attitude.roll * (180.0 / .pi)

            let clampedPitch = max(-self.maxDegrees, min(self.maxDegrees, pitchDegrees))
            let clampedRoll = max(-self.maxDegrees, min(self.maxDegrees, rollDegrees))

            self.targetPitch = clampedPitch
            self.targetRoll = clampedRoll

            DispatchQueue.main.async {
                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                    self.pitch += (self.targetPitch - self.pitch) * self.smoothingFactor
                    self.roll += (self.targetRoll - self.roll) * self.smoothingFactor
                }
            }
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        isActive = false

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.4)) {
                self.pitch = 0
                self.roll = 0
            }
        }
    }

    func resetToZero(completion: (() -> Void)? = nil) {
        let wasActive = isActive
        if wasActive { stop() }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion?()
            if wasActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.start()
                }
            }
        }
    }

    deinit {
        stop()
    }
}

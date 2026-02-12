import CoreMotion
import SwiftUI
import Combine

// MARK: - Motion Manager
// Provides device tilt data for 3-layer parallax card effect.
// Max 5° rotation with weighted (frictional) smoothing — no bounce.
//
// Parallax layers:
//   - Background: 1.0x tilt
//   - Material/specular: 1.5x tilt
//   - Name/text: 2.0x tilt

@Observable
final class MotionManager {

    var pitch: Double = 0
    var roll: Double = 0

    var isActive: Bool = false

    // 3-layer parallax convenience accessors
    var backgroundPitch: Double { pitch }
    var backgroundRoll: Double { roll }
    var materialPitch: Double { pitch * 1.5 }
    var materialRoll: Double { roll * 1.5 }
    var textPitch: Double { pitch * 2.0 }
    var textRoll: Double { roll * 2.0 }

    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private let maxDegrees: Double = 5
    private let smoothingFactor: Double = 0.12

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
                // Weighted smoothing: heavy, frictional easing (no bounce/spring)
                withAnimation(.easeOut(duration: 0.16)) {
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
            withAnimation(.easeOut(duration: 0.5)) {
                self.pitch = 0
                self.roll = 0
            }
        }
    }

    func resetToZero(completion: (() -> Void)? = nil) {
        let wasActive = isActive
        if wasActive { stop() }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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

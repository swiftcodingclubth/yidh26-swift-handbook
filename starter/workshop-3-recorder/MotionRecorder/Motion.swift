// โค้ดจากหน้า Core Motion ใน handbook
import CoreMotion

let motion = CMMotionManager()

func startMotionUpdates(onSample: @escaping (CMDeviceMotion) -> Void) {
    guard motion.isDeviceMotionAvailable else { return }   // Simulator ไม่มี sensor
    motion.deviceMotionUpdateInterval = 1.0 / 50.0         // 50 ครั้งต่อวินาที (50 Hz)
    motion.startDeviceMotionUpdates(to: .main) { data, _ in
        if let data { onSample(data) }
    }
}

func stopMotionUpdates() {
    motion.stopDeviceMotionUpdates()
}

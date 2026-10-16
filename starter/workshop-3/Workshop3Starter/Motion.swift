// โค้ดทั้งหมดในไฟล์นี้มาจากหน้า Core Motion ใน handbook
import CoreMotion

// MARK: - อ่านข้อมูลการเคลื่อนไหว

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

// MARK: - ตรวจจับท่าแบบง่ายโดยไม่ใช้ ML

func detectGesture(_ data: CMDeviceMotion) -> String? {
    let a = data.userAcceleration
    let force = (a.x * a.x + a.y * a.y + a.z * a.z).squareRoot()

    if force > 2.0 { return "เขย่า" }                      // แรงเกิน 2 g
    if abs(data.attitude.roll) > .pi / 4 { return "เอียง" }  // เอียงเกิน 45°
    return nil
}

// MARK: - Barometer

let altimeter = CMAltimeter()

func startAltitudeUpdates(onChange: @escaping (Double) -> Void) {
    guard CMAltimeter.isRelativeAltitudeAvailable() else { return }
    altimeter.startRelativeAltitudeUpdates(to: .main) { data, _ in
        if let data { onChange(data.relativeAltitude.doubleValue) }   // เมตร
    }
}

func stopAltitudeUpdates() {
    altimeter.stopRelativeAltitudeUpdates()
}

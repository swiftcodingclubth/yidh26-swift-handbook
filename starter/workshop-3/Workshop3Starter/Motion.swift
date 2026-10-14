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

// MARK: - ส่งข้อมูลให้ model ทีละช่วง

struct MotionWindow {
    let size = 100          // 100 ค่า = 2 วินาทีที่ 50 Hz ต้องเท่ากับตอน train
    var samples: [CMDeviceMotion] = []

    // ใส่ค่าใหม่ทีละค่า ถ้ายังไม่ครบ 100 ได้ nil
    // พอครบ 100 ได้ทั้งก้อนไปส่งให้ model แล้วเก็บครึ่งหลังไว้เป็นครึ่งแรกของก้อนถัดไป
    mutating func add(_ sample: CMDeviceMotion) -> [CMDeviceMotion]? {
        samples.append(sample)
        guard samples.count == size else { return nil }
        let window = samples
        samples.removeFirst(size / 2)
        return window
    }
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

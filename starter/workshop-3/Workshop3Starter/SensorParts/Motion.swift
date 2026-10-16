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

// MARK: - Use case: API เดียว

/// gravity: จอคว่ำลงโต๊ะไหม
/// แกน z ชี้ออกจากจอ จอหงายขึ้น gravity.z ≈ -1 จอคว่ำลง gravity.z ≈ +1
func isFaceDown(_ data: CMDeviceMotion) -> Bool {
    data.gravity.z > 0.9
}

/// rotationRate: บิดข้อมือเร็วๆ รอบแกน y (แกนตั้งของจอ) ได้ +1 หรือ -1 ถ้าไม่ได้บิดได้ 0
/// ถ้าทิศกลับด้านกับที่ต้องการ สลับ +1 กับ -1
func detectFlick(_ data: CMDeviceMotion) -> Int {
    let speed = data.rotationRate.y          // radian ต่อวินาที
    if speed > 4 { return 1 }
    if speed < -4 { return -1 }
    return 0
}

// MARK: - Use case: หลาย API รวมกัน

/// userAcceleration + gravity: เครื่องที่วางราบถูกยกขึ้นไหม
/// โต๊ะสั่นเบาๆ ทำให้มีแรงนิดหน่อยแต่เครื่องยังราบ จึงต้องแรงเกิน 0.3 g หรือเครื่องไม่ราบแล้ว
func detectPickup(_ data: CMDeviceMotion) -> Bool {
    let a = data.userAcceleration
    let force = (a.x * a.x + a.y * a.y + a.z * a.z).squareRoot()
    let stillFlat = data.gravity.z < -0.95   // จอหงาย เอียงไม่ถึงราว 18°
    return force > 0.3 || !stillFlat
}

/// userAcceleration + rotationRate: เหวี่ยงแบบไม้กายสิทธิ์ ต้องมีทั้งแรงพุ่งและการหมุนข้อมือพร้อมกัน
/// เขย่าตรงๆ มีแรงแต่หมุนน้อย หมุนช้าๆ มีการหมุนแต่แรงน้อย จึงไม่นับทั้งสองแบบ
func detectSwing(_ data: CMDeviceMotion) -> Bool {
    let a = data.userAcceleration
    let r = data.rotationRate
    let force = (a.x * a.x + a.y * a.y + a.z * a.z).squareRoot()
    let spin = (r.x * r.x + r.y * r.y + r.z * r.z).squareRoot()
    return force > 1.5 && spin > 5
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

// ⚠️ ปิดไว้ ไม่ได้ใช้ใน app: Gesture Classifier ถูกตัดออกจาก Workshop 3 แล้ว
// เก็บโค้ดไว้อ้างอิงเท่านั้น โค้ดทั้งหมดอยู่ใน comment จึงไม่ถูก compile
// เปิดใช้: เอา /* บรรทัดล่าง และ */ ท้ายไฟล์ออก ทั้งไฟล์นี้และ Tabs/CoreML/PredictView.swift
// แล้วเพิ่ม GestureClassifier.mlmodel กลับเข้า target (File inspector → Target Membership)
// และเพิ่ม NavigationLink ไปที่ PredictView ใน CoreMLTab.swift

/*
// โค้ดทั้งหมดในไฟล์นี้มาจากหน้า Core ML ใน handbook
// ใช้คู่กับ GestureClassifier.mlmodel (เปลี่ยนเป็น model ของทีมได้ ถ้าชื่อไฟล์และ input เหมือนกัน) และ MotionWindow ใน Motion.swift
import CoreML
import CoreMotion

final class GesturePredictor {
    private let model = try! GestureClassifier(configuration: MLModelConfiguration())
    private var state = try! MLMultiArray(shape: [400], dataType: .double)  // ขนาดดูในแท็บ Predictions

    func predict(_ window: [CMDeviceMotion]) throws -> (label: String, confidence: Double) {
        func column(_ value: (CMDeviceMotion) -> Double) throws -> MLMultiArray {
            let array = try MLMultiArray(shape: [NSNumber(value: window.count)], dataType: .double)
            for (i, sample) in window.enumerated() { array[i] = NSNumber(value: value(sample)) }
            return array
        }

        let input = GestureClassifierInput(
            accelX: try column { $0.userAcceleration.x },
            accelY: try column { $0.userAcceleration.y },
            accelZ: try column { $0.userAcceleration.z },
            rotationX: try column { $0.rotationRate.x },
            rotationY: try column { $0.rotationRate.y },
            rotationZ: try column { $0.rotationRate.z },
            stateIn: state)

        let output = try model.prediction(input: input)
        state = output.stateOut   // เก็บไว้ใช้ครั้งถัดไป
        return (output.label, output.labelProbability[output.label] ?? 0)
    }
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
*/

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

// โค้ดในไฟล์นี้มาจากหน้า Core ML หัวข้อ "หาวัตถุในรูปด้วย YOLOv3"
// ใช้คู่กับ YOLOv3Tiny.mlmodel ที่ดาวน์โหลดจาก developer.apple.com/machine-learning/models
import CoreML
import UIKit
import Vision

/// วัตถุหนึ่งชิ้นที่เจอในรูป
struct DetectedObject: Identifiable {
    let id = UUID()
    let label: String        // ชื่อวัตถุภาษาอังกฤษ เช่น "dog", "person"
    let confidence: Double   // 0–1
    let box: CGRect          // ตำแหน่ง 0–1 มุมบนซ้ายเป็น (0, 0) แบบ SwiftUI
}

final class ObjectDetector {
    private let model = try! YOLOv3Tiny(configuration: MLModelConfiguration()).model

    func detect(in image: UIImage) async throws -> [DetectedObject] {
        // วาดรูปใหม่ให้ตั้งตรงก่อน รูปจากกล้อง iPad มักเก็บแบบหมุนไว้
        let upright = UIGraphicsImageRenderer(size: image.size).image { _ in image.draw(at: .zero) }
        guard let cgImage = upright.cgImage else { return [] }

        // ให้ Vision ช่วยย่อรูปเป็น 416 × 416 และแปลงผลจาก model เป็นชื่อวัตถุกับกรอบ
        var request = try CoreMLRequest(model: CoreMLModelContainer(model: model))
        request.cropAndScaleAction = .scaleToFill   // ใช้ทั้งรูป ไม่ตัดขอบ
        let results = try await request.perform(on: cgImage)

        return results.compactMap { $0 as? RecognizedObjectObservation }.map { object in
            let rect = object.boundingBox.cgRect   // Vision: (0, 0) อยู่มุมล่างซ้าย
            return DetectedObject(
                label: object.labels.first?.identifier ?? "?",
                confidence: Double(object.labels.first?.confidence ?? 0),
                box: CGRect(x: rect.minX, y: 1 - rect.maxY, width: rect.width, height: rect.height))
        }
    }
}

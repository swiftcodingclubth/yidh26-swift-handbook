// โค้ดในไฟล์นี้มาจากหน้า Core ML หัวข้อ "ใช้ model สำเร็จรูปจาก Apple"
// ใช้คู่กับ MobileNetV2.mlmodel ที่ดาวน์โหลดจาก developer.apple.com/machine-learning/models
import CoreML
import UIKit

final class ImageClassifier {
    private let model = try! MobileNetV2(configuration: MLModelConfiguration())

    func classify(_ image: UIImage) throws -> (label: String, confidence: Double) {
        guard let cgImage = image.cgImage else { return ("?", 0) }
        let input = try MobileNetV2Input(imageWith: cgImage)   // ย่อรูปเป็น 224 × 224 ให้เอง
        let output = try model.prediction(input: input)

        // ชื่อมีหลายแบบคั่นด้วยจุลภาค เช่น "golden retriever, ..." เอาแค่ชื่อแรก
        let name = output.classLabel.components(separatedBy: ",").first ?? output.classLabel
        return (name, output.classLabelProbs[output.classLabel] ?? 0)
    }
}

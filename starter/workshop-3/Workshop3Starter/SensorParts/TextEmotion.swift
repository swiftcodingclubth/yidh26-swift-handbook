// จำแนกอารมณ์จากข้อความภาษาอังกฤษ ด้วย text classifier ที่ train เองใน Create ML
// ใช้คู่กับ EmotionClassifier.mlmodel (6 อารมณ์: joy, sadness, anger, fear, love, surprise)
import CoreML
import NaturalLanguage

final class EmotionDetector {
    // Text classifier ใช้ผ่าน NLModel ของ Natural Language
    private let model = try! NLModel(mlModel: EmotionClassifier(configuration: MLModelConfiguration()).model)

    /// ความมั่นใจของทุกอารมณ์ เรียงจากมากไปน้อย เช่น [("joy", 0.82), ("love", 0.10), …]
    func scores(for text: String) -> [(label: String, confidence: Double)] {
        model.predictedLabelHypotheses(for: text, maximumCount: 6)
            .map { (label: $0.key, confidence: $0.value) }
            .sorted { $0.confidence > $1.confidence }
    }
}

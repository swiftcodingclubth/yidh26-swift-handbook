// โค้ดในไฟล์นี้มาจากหน้า Core ML หัวข้อ "ใช้ model ของคนอื่น" และ Workshop
// ใช้ได้กับ image classifier ทุกตัว ทั้งที่ train เองใน Create ML, ของ Apple และของคนอื่น
// โหลด model จากชื่อไฟล์ จึงไม่ต้องรู้ชื่อ class ล่วงหน้า และ build ผ่านแม้ยังไม่มีไฟล์ model
import CoreImage
import CoreML
import UIKit
import Vision

struct ImageGuess: Identifiable {
    var id: String { label }
    let label: String
    let confidence: Double   // 0–1
}

final class AnyImageClassifier {
    private let model: CoreMLModelContainer

    /// ชื่อไฟล์ model ไม่ต้องมีนามสกุล เช่น ไฟล์ DeskClassifier.mlmodel ใช้ชื่อ "DeskClassifier"
    /// ถ้าไม่มีไฟล์นี้ใน project ได้ nil
    init?(named name: String) {
        // Xcode compile ไฟล์ .mlmodel และ .mlpackage เป็น .mlmodelc ตอน build
        guard let url = Bundle.main.url(forResource: name, withExtension: "mlmodelc"),
              let mlModel = try? MLModel(contentsOf: url),
              let container = try? CoreMLModelContainer(model: mlModel) else { return nil }
        model = container
    }

    /// ทายจากรูปใน Photos ได้คำตอบเรียงจากมั่นใจมากไปน้อย
    func classify(_ image: UIImage) async throws -> [ImageGuess] {
        // วาดรูปใหม่ให้ตั้งตรงก่อน รูปจากกล้อง iPad มักเก็บแบบหมุนไว้
        let upright = UIGraphicsImageRenderer(size: image.size).image { _ in image.draw(at: .zero) }
        guard let cgImage = upright.cgImage else { return [] }
        return try await classify(CIImage(cgImage: cgImage))
    }

    /// ทายจาก frame ของกล้องสด (frame จาก CameraView ตั้งตรงแล้ว)
    func classify(_ frame: CVPixelBuffer) async throws -> [ImageGuess] {
        try await classify(CIImage(cvPixelBuffer: frame))
    }

    private func classify(_ image: CIImage) async throws -> [ImageGuess] {
        // Vision ย่อรูปให้ตรงขนาดที่ model ต้องการเอง ไม่ว่า model จะรับรูปขนาดเท่าไหร่
        var request = CoreMLRequest(model: model)
        request.cropAndScaleAction = .centerCrop
        let results = try await request.perform(on: image)

        return results.compactMap { $0 as? ClassificationObservation }
            .map { ImageGuess(label: $0.identifier, confidence: Double($0.confidence)) }
            .sorted { $0.confidence > $1.confidence }
    }
}

import UIKit
import Vision

/// อ่านข้อความทุกบรรทัดในรูป ได้ 1 `String` ต่อ 1 บรรทัด
func readText(from image: UIImage) async throws -> [String] {
    guard let cgImage = image.cgImage else { return [] }

    // 1. สร้าง request
    var request = RecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.recognitionLanguages = supportedLanguages(["th", "en"], in: request)

    // 2. perform กับรูป: บอกทิศของรูปด้วย ไม่อย่างนั้นรูปจากกล้องที่หมุนอยู่จะอ่านไม่ออก
    let observations = try await request.perform(
        on: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))

    // 3. อ่านผล: แต่ละ observation คือ 1 บรรทัด
    return observations.map(\.transcript)
}

/// เลือกเฉพาะภาษาที่เครื่องนี้รองรับ ถ้าใส่ภาษาที่ไม่รองรับ request จะ error
private func supportedLanguages(_ codes: [String], in request: RecognizeTextRequest) -> [Locale.Language] {
    codes.compactMap { code in
        request.supportedRecognitionLanguages.first { $0.languageCode?.identifier == code }
    }
}

extension CGImagePropertyOrientation {
    /// แปลงทิศของ `UIImage` เป็นแบบที่ Vision ใช้
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}

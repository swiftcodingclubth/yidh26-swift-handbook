import AVFoundation
import SwiftUI

/// ตัวอย่างจากหน้า Core ML หัวข้อ "หาวัตถุจากกล้องแบบ real time"
/// หันกล้องหลังไปที่ไหนก็ได้ YOLOv3 ตีกรอบวัตถุที่เจอให้ทันที
/// ต้อง run บน iPad จริง (Simulator ไม่มีกล้อง) และต้องมี NSCameraUsageDescription
struct LiveDetectView: View {
    @State private var model = LiveDetector()

    var body: some View {
        CameraView(position: .back, onFrame: model.handle) {
            ObjectBoxes(objects: model.objects)   // กรอบอยู่ในกรอบเดียวกับภาพจากกล้องพอดี
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            Text(model.objects.isEmpty ? "หันกล้องไปที่คน สัตว์ หรือสิ่งของ" : objectSummary(model.objects))
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .glassEffect(.regular, in: .capsule)
                .padding(.bottom, 24)
                .contentTransition(.opacity)
                .animation(.easeInOut, value: model.objects.map(\.label))
        }
    }
}

/// รับ frame จากกล้อง แล้วให้ ObjectDetector ทายทีละ frame
@MainActor @Observable
final class LiveDetector {
    private(set) var objects: [DetectedObject] = []

    private let detector = ObjectDetector()
    private var isBusy = false

    func handle(_ frame: CVPixelBuffer) {
        guard !isBusy else { return }   // frame ก่อนหน้ายังทายไม่เสร็จ ข้ามไปก่อน app จะได้ไม่หน่วง
        isBusy = true
        Task {
            defer { isBusy = false }
            objects = (try? await detector.detect(in: frame)) ?? []
        }
    }
}

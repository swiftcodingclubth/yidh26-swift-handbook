import CoreMotion
import SwiftUI

/// ตัวอย่างจากหน้า Core ML หัวข้อ "ทายท่าด้วย model"
/// กดเริ่ม ทำท่า แล้วกดหยุด model จึงบอกว่าเป็นท่าอะไร
/// ลองทำท่า shake, tilt, circle หรือถือนิ่งๆ (idle) อย่างน้อย 2 วินาที
struct PredictView: View {
    @State private var isRecording = false
    @State private var recorded: [CMDeviceMotion] = []
    @State private var label = "–"
    @State private var confidence = 0.0
    @State private var message = "กดเริ่ม แล้วทำท่าอย่างน้อย 2 วินาที"

    var body: some View {
        VStack(spacing: 24) {
            Text(isRecording ? "กำลังอัด…" : label)
                .font(.system(size: 80, weight: .bold))
                .monospaced()
            ProgressView(value: isRecording ? 0 : confidence)
                .frame(width: 300)
            Text(isRecording
                 ? String(format: "%.1f วินาที", Double(recorded.count) / 50)
                 : "ความมั่นใจ \(Int(confidence * 100))%")
                .font(.title2)
                .monospacedDigit()
            Text(message)
                .foregroundStyle(.secondary)

            Button(isRecording ? "หยุดและทาย" : "เริ่มทำท่า",
                   systemImage: isRecording ? "stop.fill" : "record.circle") {
                isRecording ? stop() : start()
            }
            .buttonStyle(.borderedProminent)
            .tint(isRecording ? .red : .accentColor)
            .controlSize(.large)
        }
        .navigationTitle("GesturePredictor")
        .onDisappear { stopMotionUpdates() }
    }

    // 1. กดเริ่ม: เก็บค่าไว้ก่อน ยังไม่ทาย
    private func start() {
        recorded = []
        isRecording = true
        startMotionUpdates { sample in
            recorded.append(sample)
        }
    }

    // 2. กดหยุด: หยุด sensor แล้วค่อยทายจากข้อมูลทั้งหมดที่อัดไว้
    private func stop() {
        stopMotionUpdates()
        isRecording = false

        guard recorded.count >= 100 else {   // model ต้องการข้อมูลก้อนละ 100 ค่า (2 วินาที)
            label = "–"
            confidence = 0
            message = "สั้นไป ทำท่าอย่างน้อย 2 วินาที แล้วลองใหม่"
            return
        }

        var window = MotionWindow()
        let predictor = GesturePredictor()   // สร้างใหม่ทุกครั้ง ความจำ (stateIn) จะได้เริ่มจากว่าง
        var scores: [String: Double] = [:]   // ชื่อท่า → ความมั่นใจรวมทุกก้อน
        var count = 0
        for sample in recorded {
            if let samples = window.add(sample),           // หั่นเป็นก้อนละ 100 ค่า
               let result = try? predictor.predict(samples) {
                scores[result.label, default: 0] += result.confidence
                count += 1
            }
        }

        // ท่าที่ความมั่นใจรวมสูงสุด คือคำตอบ
        guard let best = scores.max(by: { $0.value < $1.value }) else { return }
        label = best.key
        confidence = best.value / Double(count)   // เฉลี่ยต่อก้อน
        message = String(format: "ทายจากข้อมูล %.1f วินาที (%d ก้อน)", Double(recorded.count) / 50, count)
    }
}

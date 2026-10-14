import CoreMotion
import SwiftUI

/// ตัวอย่างจากหน้า Core ML หัวข้อ "ต่อเข้ากับ Core Motion"
/// ทำท่าแล้ว model บอกว่าทำท่าไหนอยู่ ได้ผลใหม่ทุก 1 วินาที
/// ลองทำท่า shake, tilt, circle หรือถือนิ่งๆ (idle)
struct PredictView: View {
    @State private var window = MotionWindow()
    @State private var predictor = GesturePredictor()
    @State private var label = "–"
    @State private var confidence = 0.0

    var body: some View {
        VStack(spacing: 24) {
            Text(label)
                .font(.system(size: 80, weight: .bold))
                .monospaced()
            ProgressView(value: confidence)
                .frame(width: 300)
            Text("ความมั่นใจ \(Int(confidence * 100))%")
                .font(.title2)
                .monospacedDigit()
            Text("ทายทุก 1 วินาที จากข้อมูล 2 วินาทีล่าสุด")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("GesturePredictor")
        .onAppear {
            startMotionUpdates { sample in
                if let samples = window.add(sample),
                   let result = try? predictor.predict(samples) {
                    label = result.label
                    confidence = result.confidence
                }
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}

import CoreMotion
import SwiftUI

/// Use case: คว่ำเครื่องลงโต๊ะเพื่อเริ่มจับเวลาอ่านหนังสือ หงายขึ้นเพื่อหยุด
/// ใช้ isFaceDown (gravity.z) จาก handbook
struct FaceDownTimerView: View {
    @State private var faceDownSince: Date?      // เวลาที่เริ่มคว่ำ ถ้ายังหงายอยู่เป็น nil
    @State private var total: TimeInterval = 0   // เวลาที่คว่ำสะสมทั้งหมด
    @State private var gravityZ = 0.0

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: faceDownSince == nil ? "book" : "book.closed")
                .font(.system(size: 72))
            Text(faceDownSince == nil ? "คว่ำเครื่องลงโต๊ะเพื่อเริ่มจับเวลา" : "กำลังจับเวลา…")
                .font(.title)
            Text("อ่านไปแล้ว \(format(total))")
                .font(.system(size: 64, weight: .bold))
                .monospacedDigit()
            Text(String(format: "gravity.z = %+.2f", gravityZ))
                .font(.title3)
                .monospacedDigit()
                .foregroundStyle(.secondary)
            Button("เริ่มใหม่") { total = 0 }
                .buttonStyle(.bordered)
                .disabled(faceDownSince != nil)
        }
        .navigationTitle("คว่ำเครื่องจับเวลา")
        .onAppear {
            startMotionUpdates { data in
                gravityZ = data.gravity.z
                let down = isFaceDown(data)
                if down, faceDownSince == nil {
                    faceDownSince = .now                     // เพิ่งคว่ำ: เริ่มจับเวลา
                } else if !down, let start = faceDownSince {
                    total += Date.now.timeIntervalSince(start) // เพิ่งหงาย: บวกเวลาที่คว่ำไว้
                    faceDownSince = nil
                }
            }
        }
        .onDisappear { stopMotionUpdates() }
    }

    private func format(_ seconds: TimeInterval) -> String {
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

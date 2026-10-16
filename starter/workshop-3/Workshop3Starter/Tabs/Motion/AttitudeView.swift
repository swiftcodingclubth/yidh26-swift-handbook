import CoreMotion
import SwiftUI

/// ตัวอย่างจากหน้า Core Motion หัวข้อ "มุมของเครื่อง: roll, pitch, yaw"
/// วาง iPad ราบบนโต๊ะ แล้วลอง พยักหน้า (pitch) เอียงคอ (roll) ส่ายหน้า (yaw)
struct AttitudeView: View {
    @State private var pitch = 0.0
    @State private var roll = 0.0
    @State private var yaw = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            angle("pitch", pitch, hint: "ยกขอบบนขึ้น หรือกดขอบบนลง (หมุนรอบแกน x)")
            angle("roll", roll, hint: "ยกขอบซ้ายหรือขอบขวาขึ้น (หมุนรอบแกน y)")
            angle("yaw", yaw, hint: "หมุนเครื่องบนโต๊ะโดยไม่ยกขึ้น (หมุนรอบแกน z)")
            Text("วางเครื่องราบบนโต๊ะ จอหันขึ้น แล้วลองทีละท่า yaw = 0° คือทิศที่เครื่องหันอยู่ตอนเปิดหน้านี้ ไม่ใช่ทิศเหนือ")
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .navigationTitle("Attitude")
        .onAppear {
            startMotionUpdates { data in
                pitch = data.attitude.pitch * 180 / .pi   // radian → องศา
                roll = data.attitude.roll * 180 / .pi
                yaw = data.attitude.yaw * 180 / .pi
            }
        }
        .onDisappear { stopMotionUpdates() }
    }

    private func angle(_ name: String, _ degrees: Double, hint: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(name): \(degrees, specifier: "%.0f")°")
                .font(.largeTitle)
                .monospacedDigit()
            Text(hint)
                .foregroundStyle(.secondary)
        }
    }
}

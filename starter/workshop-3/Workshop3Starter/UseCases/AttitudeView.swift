import CoreMotion
import SwiftUI

/// ตัวอย่างจากหน้า Core Motion หัวข้อ "มุมของเครื่อง: roll, pitch, yaw"
/// วาง iPad ราบบนโต๊ะ แล้วลอง พยักหน้า (pitch) เอียงคอ (roll) ส่ายหน้า (yaw)
struct AttitudeView: View {
    @State private var pitch = 0.0
    @State private var roll = 0.0
    @State private var yaw = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("pitch: \(pitch, specifier: "%.0f")°")
            Text("roll: \(roll, specifier: "%.0f")°")
            Text("yaw: \(yaw, specifier: "%.0f")°")
        }
        .font(.largeTitle)
        .monospacedDigit()
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
}

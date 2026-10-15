import CoreMotion
import SwiftUI

/// Use case: ที่วัดระดับน้ำ เช็กว่าโต๊ะหรือชั้นวางเอียงไหม
/// วาง iPad ราบบนโต๊ะ ถ้าเส้นเป็นสีเขียวแปลว่าโต๊ะไม่เอียง
struct LevelView: View {
    @State private var roll = 0.0   // มุมเอียงซ้าย-ขวา (radian) จาก attitude

    var body: some View {
        let degrees = roll * 180 / .pi
        let isLevel = abs(degrees) < 1   // เอียงไม่ถึง 1° ถือว่าตรง

        VStack(spacing: 40) {
            Text(String(format: "%.1f°", degrees))
                .font(.system(size: 80, weight: .bold))
                .monospacedDigit()

            // เส้นหมุนตามมุมเอียงของเครื่อง
            Capsule()
                .fill(isLevel ? .green : .orange)
                .frame(width: 300, height: 12)
                .rotationEffect(.radians(-roll))

            Text(isLevel ? "ตรงแล้ว" : "ยังเอียงอยู่")
                .font(.title)
        }
        .navigationTitle("ที่วัดระดับน้ำ")
        .onAppear {
            startMotionUpdates { data in
                roll = data.attitude.roll
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}

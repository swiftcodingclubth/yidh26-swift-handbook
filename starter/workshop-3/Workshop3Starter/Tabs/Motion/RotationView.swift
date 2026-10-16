import CoreMotion
import SwiftUI

/// ตัวอย่างจากหน้า Core Motion หัวข้อ "rotationRate: หมุนเร็วแค่ไหน"
/// บอกความเร็วการหมุนรอบแต่ละแกน ไม่ใช่มุม หยุดหมุนเมื่อไหร่ ค่ากลับเป็น 0 ทันที
struct RotationView: View {
    @State private var x = 0.0
    @State private var y = 0.0
    @State private var z = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("ความเร็วการหมุน (rad/s)")
                .font(.largeTitle.bold())
            AxisBar(name: "x", detail: "ยกขอบบนขึ้นลง", value: x, unit: "rad/s", fullScale: 5)
            AxisBar(name: "y", detail: "ยกขอบซ้ายขวา", value: y, unit: "rad/s", fullScale: 5)
            AxisBar(name: "z", detail: "หมุนบนโต๊ะ", value: z, unit: "rad/s", fullScale: 5)
            VStack(alignment: .leading, spacing: 8) {
                Text("ลองแบบนี้").font(.headline)
                Text("หมุนช้า ๆ แล้วหมุนเร็ว ๆ ดูว่าแถบยาวต่างกันแค่ไหน")
                Text("เอียงเครื่องค้างไว้ ค่ากลับเป็น 0 ต่างจาก attitude ที่ค้างมุมไว้")
                Text("1 รอบ = 2π ≈ 6.3 radian หมุนครบรอบใน 1 วินาทีได้ราว 6.3 rad/s")
            }
            .foregroundStyle(.secondary)
        }
        .padding(32)
        .navigationTitle("Rotation rate")
        .onAppear {
            startMotionUpdates { data in
                x = data.rotationRate.x
                y = data.rotationRate.y
                z = data.rotationRate.z
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}

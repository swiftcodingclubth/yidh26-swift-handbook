import CoreMotion
import SwiftUI

/// ตัวอย่างจากหน้า Core Motion หัวข้อ "gravity: เครื่องอยู่ในท่าไหน"
/// แรงโน้มถ่วงชี้ลงพื้นเสมอ แกนที่ชี้ลงพื้นจะมีค่าใกล้ ±1 g ลองวางเครื่องหลายท่าแล้วดูว่าแกนไหนเต็ม
struct GravityView: View {
    @State private var x = 0.0
    @State private var y = 0.0
    @State private var z = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("ทิศแรงโน้มถ่วง (g)")
                .font(.largeTitle.bold())
            AxisBar(name: "x", detail: "ตั้งเครื่องแนวนอน", value: x, fullScale: 1)
            AxisBar(name: "y", detail: "ตั้งเครื่องแนวตั้ง", value: y, fullScale: 1)
            AxisBar(name: "z", detail: "วางราบ หงาย / คว่ำ", value: z, fullScale: 1)
            VStack(alignment: .leading, spacing: 8) {
                Text("ลองวางเครื่องแบบนี้").font(.headline)
                Text("วางราบบนโต๊ะ จอหงายขึ้น → z ≈ -1")
                Text("ตั้งเครื่องแนวตั้งตรงหน้า → y ≈ -1")
                Text("คว่ำจอลงโต๊ะ → z ≈ +1")
                Text("ขยับเร็ว ๆ แล้วค่าแทบไม่เปลี่ยน เพราะการขยับไปอยู่ใน userAcceleration")
            }
            .foregroundStyle(.secondary)
        }
        .padding(32)
        .navigationTitle("Gravity")
        .onAppear {
            startMotionUpdates { data in
                x = data.gravity.x
                y = data.gravity.y
                z = data.gravity.z
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}

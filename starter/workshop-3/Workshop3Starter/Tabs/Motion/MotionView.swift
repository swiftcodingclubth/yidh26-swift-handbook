import CoreMotion
import SwiftUI

/// ตัวอย่างจากหน้า Core Motion ขยายให้ดูครบทั้ง 3 แกน
/// ลองเหวี่ยง iPad ซ้าย-ขวา (x) ขึ้น-ลง (y) และเข้าหา-ออกจากตัว (z) แล้วดูว่าแถบไหนขยับ
struct MotionView: View {
    @State private var x = 0.0
    @State private var y = 0.0
    @State private var z = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("แรงเหวี่ยง (g)")
                .font(.largeTitle.bold())
            AxisBar(name: "x", detail: "ซ้าย-ขวา", value: x)
            AxisBar(name: "y", detail: "ขึ้น-ลง", value: y)
            AxisBar(name: "z", detail: "เข้าหา-ออกจากตัว", value: z)
        }
        .padding(32)
        .onAppear {
            startMotionUpdates { data in
                x = data.userAcceleration.x
                y = data.userAcceleration.y
                z = data.userAcceleration.z
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}

/// ค่าหนึ่งแกน: แถบยืดจากตรงกลาง ไปทางขวาเมื่อค่าเป็นบวก ไปทางซ้ายเมื่อค่าเป็นลบ
/// แถบเต็มครึ่งหนึ่งเมื่อแรงถึง 2 g
private struct AxisBar: View {
    let name: String
    let detail: String
    let value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("แกน \(name)").font(.title2.bold())
                Text(detail).foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%+.2f g", value))
                    .font(.title2)
                    .monospacedDigit()
            }
            GeometryReader { geo in
                let half = geo.size.width / 2
                let fraction = min(max(value / 2, -1), 1)
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Rectangle()
                        .fill(fraction >= 0 ? Color.blue : Color.orange)
                        .frame(width: abs(fraction) * half)
                        .offset(x: fraction >= 0 ? half : half + fraction * half)
                    Rectangle()   // เส้นกลาง = 0 g
                        .fill(.secondary)
                        .frame(width: 2)
                        .offset(x: half - 1)
                }
                .clipShape(Capsule())
            }
            .frame(height: 20)
        }
    }
}

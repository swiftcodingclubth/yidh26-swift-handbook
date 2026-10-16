import CoreMotion
import SwiftUI

/// Use case: ไม้กายสิทธิ์ ตวัดเครื่องเพื่อร่ายเวท
/// ใช้ detectSwing (userAcceleration + rotationRate) จาก handbook ลองเขย่าตรงๆ ดูว่าไม่นับ แล้วลองตวัดข้อมือ
struct MagicWandView: View {
    @State private var spell = "ตวัดเครื่องเพื่อร่ายเวท"
    @State private var count = 0
    @State private var lastSwing = Date.distantPast
    @State private var force = 0.0
    @State private var spin = 0.0

    private let spells = ["🔥 ลูกไฟ", "❄️ น้ำแข็ง", "⚡️ สายฟ้า", "🌪️ พายุ", "✨ แสงวิเศษ"]

    var body: some View {
        VStack(spacing: 32) {
            Text(spell)
                .font(.system(size: 56, weight: .bold))
                .id(count)
                .transition(.scale.combined(with: .opacity))
            Text("ร่ายไปแล้ว \(count) ครั้ง")
                .font(.title2)
            VStack(alignment: .leading, spacing: 12) {
                Meter(name: "แรงพุ่ง", value: force, limit: 1.5, unit: "g")
                Meter(name: "การหมุน", value: spin, limit: 5, unit: "rad/s")
            }
            .frame(maxWidth: 500)
        }
        .padding(32)
        .navigationTitle("ไม้กายสิทธิ์")
        .onAppear {
            startMotionUpdates { data in
                let a = data.userAcceleration
                let r = data.rotationRate
                force = (a.x * a.x + a.y * a.y + a.z * a.z).squareRoot()
                spin = (r.x * r.x + r.y * r.y + r.z * r.z).squareRoot()

                guard detectSwing(data), Date.now.timeIntervalSince(lastSwing) > 1 else { return }
                lastSwing = .now
                withAnimation(.spring(duration: 0.4, bounce: 0.5)) {
                    count += 1
                    spell = spells.randomElement()!
                }
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}

/// แถบแสดงค่า เปลี่ยนเป็นสีเขียวเมื่อเกินเกณฑ์ที่ detectSwing ใช้
private struct Meter: View {
    let name: String
    let value: Double
    let limit: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(name) \(String(format: "%.1f", value)) \(unit) (เกณฑ์ \(String(format: "%.1f", limit)))")
                .monospacedDigit()
            ProgressView(value: min(value / (limit * 2), 1))
                .tint(value > limit ? .green : .gray)
        }
    }
}

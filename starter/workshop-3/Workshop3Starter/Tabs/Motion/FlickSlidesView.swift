import CoreMotion
import SwiftUI

/// Use case: บิดข้อมือเร็วๆ เพื่อเปลี่ยนสไลด์ ไม่ต้องแตะจอ
/// ใช้ detectFlick (rotationRate.y) จาก handbook ถือเครื่องตั้งขึ้น จอหันเข้าหาตัว แล้วบิดข้อมือซ้ายหรือขวา
struct FlickSlidesView: View {
    @State private var index = 0
    @State private var lastFlick = Date.distantPast
    @State private var speed = 0.0

    private let slides: [(title: String, color: Color)] = [
        ("Core Motion", .blue),
        ("userAcceleration", .orange),
        ("attitude", .green),
        ("gravity", .purple),
        ("rotationRate", .pink),
    ]

    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 24)
                .fill(slides[index].color.gradient)
                .overlay {
                    Text(slides[index].title)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: 600, maxHeight: 360)
                .id(index)
                .transition(.push(from: .trailing))
            Text("สไลด์ \(index + 1) / \(slides.count)")
                .font(.title2)
            Text(String(format: "rotationRate.y = %+.1f rad/s", speed))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .navigationTitle("บิดข้อมือเปลี่ยนสไลด์")
        .onAppear {
            startMotionUpdates { data in
                speed = data.rotationRate.y
                let direction = detectFlick(data)
                // บิดหนึ่งครั้งมีค่าเกินเกณฑ์หลาย sample จึงรอ 0.6 วินาทีก่อนนับครั้งใหม่
                guard direction != 0, Date.now.timeIntervalSince(lastFlick) > 0.6 else { return }
                lastFlick = .now
                withAnimation {
                    index = (index + direction + slides.count) % slides.count
                }
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}

import CoreMotion
import SwiftUI

/// Use case: เขย่า iPad เพื่อสุ่มว่ามื้อเที่ยงกินอะไรดี
/// ใช้ detectGesture จาก handbook: เขย่าแรงเกิน 2 g จะได้ "เขย่า"
struct ShakeMenuView: View {
    @State private var menu = "เขย่าเลย!"
    @State private var gesture = "–"

    private let menus = ["ข้าวมันไก่", "กะเพราหมูสับ", "ก๋วยเตี๋ยวเรือ", "ส้มตำ", "ข้าวผัด", "ผัดไทย"]

    var body: some View {
        VStack(spacing: 32) {
            Text("วันนี้กินอะไรดี?")
                .font(.title)
            Text(menu)
                .font(.system(size: 64, weight: .bold))
            Text("ท่าล่าสุด: \(gesture)")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("เขย่าสุ่มเมนู")
        .onAppear {
            startMotionUpdates { data in
                if let found = detectGesture(data) {
                    gesture = found
                    if found == "เขย่า" {
                        menu = menus.randomElement()!
                    }
                }
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}

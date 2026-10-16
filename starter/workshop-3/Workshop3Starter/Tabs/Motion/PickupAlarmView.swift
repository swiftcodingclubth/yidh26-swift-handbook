import CoreMotion
import SwiftUI

/// Use case: เตือนเมื่อมีคนหยิบเครื่องขึ้นจากโต๊ะ
/// ใช้ detectPickup (userAcceleration + gravity) จาก handbook วางเครื่องราบบนโต๊ะ จอหงาย แล้วกดเริ่มเฝ้า
struct PickupAlarmView: View {
    private enum Mode { case idle, armed, triggered }

    @State private var mode = Mode.idle
    @State private var armedAt = Date.distantPast

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: icon)
                .font(.system(size: 96))
            Text(message)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Button(mode == .idle ? "เริ่มเฝ้า" : "หยุด") {
                if mode == .idle {
                    mode = .armed
                    armedAt = .now
                } else {
                    mode = .idle
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color.opacity(0.35))
        .animation(.easeInOut, value: mode)
        .navigationTitle("เตือนเมื่อมีคนหยิบเครื่อง")
        .onAppear {
            startMotionUpdates { data in
                // รอ 1 วินาทีหลังกดเริ่ม เพราะการแตะปุ่มทำให้เครื่องสั่นเล็กน้อย
                guard mode == .armed, Date.now.timeIntervalSince(armedAt) > 1 else { return }
                if detectPickup(data) { mode = .triggered }
            }
        }
        .onDisappear { stopMotionUpdates() }
    }

    private var icon: String {
        switch mode {
        case .idle: "lock.open"
        case .armed: "lock.shield"
        case .triggered: "exclamationmark.triangle.fill"
        }
    }

    private var message: String {
        switch mode {
        case .idle: "วางเครื่องราบบนโต๊ะ\nแล้วกดเริ่มเฝ้า"
        case .armed: "กำลังเฝ้าอยู่"
        case .triggered: "มีคนหยิบเครื่อง!"
        }
    }

    private var color: Color {
        switch mode {
        case .idle: .gray
        case .armed: .green
        case .triggered: .red
        }
    }
}

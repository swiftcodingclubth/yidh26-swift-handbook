import SwiftUI

/// Use case: เตือนผู้พิการทางสายตาเมื่อมีสิ่งกีดขวางข้างหน้า
/// ถือ iPad ให้กล้องหลังหันไปข้างหน้า แล้วเดินเข้าหากำแพงช้า ๆ
/// จอเปลี่ยนสีตามระยะ: เขียว = ทางโล่ง, ส้ม = ระวัง, แดง = หยุด
struct ObstacleView: View {
    @State private var reader = DepthReader()
    @State private var meters: Float = 0
    @State private var lastUpdate = Date.distantPast

    var body: some View {
        Group {
            if hasLiDAR {
                VStack(spacing: 24) {
                    Text(warning.text)
                        .font(.system(size: 80, weight: .bold))
                    Text(String(format: "%.1f m", meters))
                        .font(.largeTitle)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(warning.color.opacity(0.4))
                .animation(.easeInOut, value: warning.text)
            } else {
                NoLiDARView()
            }
        }
        .navigationTitle("เตือนสิ่งกีดขวาง")
        .onAppear {
            reader.onDistance = { distance in
                guard Date.now.timeIntervalSince(lastUpdate) > 0.2 else { return }
                meters = distance
                lastUpdate = .now
            }
            reader.start()
        }
        .onDisappear { reader.stop() }
    }

    // เปลี่ยนตัวเลข 0.5 และ 1.0 เมตรได้ตามต้องการ
    private var warning: (text: String, color: Color) {
        if meters < 0.5 { return ("หยุด!", .red) }
        if meters < 1.0 { return ("ระวัง", .orange) }
        return ("ทางโล่ง", .green)
    }
}

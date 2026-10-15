import SwiftUI

/// ตัวอย่างจากหน้า LiDAR: วัดระยะของสิ่งที่อยู่ตรงกลางภาพ
/// หันกล้องหลังของ iPad ไปที่สิ่งของ แล้วเดินเข้าใกล้หรือถอยออก
struct DepthView: View {
    @State private var reader = DepthReader()
    @State private var meters: Float = 0
    @State private var lastUpdate = Date.distantPast

    var body: some View {
        VStack(spacing: 24) {
            if hasLiDAR {
                Image(systemName: "scope")
                    .font(.system(size: 60))
                Text(String(format: "%.2f m", meters))
                    .font(.system(size: 96, weight: .bold))
                    .monospacedDigit()
                Text("ระยะของสิ่งที่อยู่ตรงกลางกล้องหลัง")
                    .foregroundStyle(.secondary)
            } else {
                NoLiDARView()
            }
        }
        .navigationTitle("DepthView")
        .onAppear {
            reader.onDistance = { distance in
                // ARKit ส่งค่ามา 60 ครั้งต่อวินาที อัปเดตจอแค่ 5 ครั้งต่อวินาทีก็พอ
                guard Date.now.timeIntervalSince(lastUpdate) > 0.2 else { return }
                meters = distance
                lastUpdate = .now
            }
            reader.start()
        }
        .onDisappear { reader.stop() }   // กล้องกับ LiDAR กินแบตเตอรี่มาก
    }
}

/// แสดงเมื่อเครื่องไม่มี LiDAR เช่น iPad รุ่นธรรมดา หรือ Simulator
struct NoLiDARView: View {
    var body: some View {
        ContentUnavailableView(
            "เครื่องนี้ไม่มี LiDAR",
            systemImage: "camera.metering.unknown",
            description: Text("LiDAR มีเฉพาะ iPad Pro และ iPhone Pro ลองหน้า Core Motion หรือ Sound แทน")
        )
    }
}

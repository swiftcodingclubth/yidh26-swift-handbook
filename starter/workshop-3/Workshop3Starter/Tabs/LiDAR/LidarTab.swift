import SwiftUI

/// ขั้น 3: LiDAR — วัดระยะด้วยข้อมูลความลึก
/// ใช้โค้ดใน SensorParts/Lidar.swift มีเฉพาะ iPad Pro และ iPhone Pro เครื่องอื่นจะขึ้นข้อความว่าไม่มี LiDAR
struct LidarTab: View {
    private enum Page: Hashable { case depth, obstacle }

    var body: some View {
        NavigationStack {
            List {
                Section("ตัวอย่างใน handbook") {
                    NavigationLink(value: Page.depth) {
                        UseCaseRow(title: "DepthView", detail: "ระยะของสิ่งที่อยู่กลางจอ · DepthReader", icon: "scope")
                    }
                }
                Section("Use case") {
                    NavigationLink(value: Page.obstacle) {
                        UseCaseRow(title: "เตือนสิ่งกีดขวาง", detail: "สำหรับผู้พิการทางสายตา · เปลี่ยนสีตามระยะ", icon: "figure.walk.motion")
                    }
                }
                Section {
                    Text("มีเฉพาะ iPad Pro และ iPhone Pro ต้อง run บนเครื่องจริง")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("LiDAR")
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .depth: DepthView()
                case .obstacle: ObstacleView()
                }
            }
        }
    }
}

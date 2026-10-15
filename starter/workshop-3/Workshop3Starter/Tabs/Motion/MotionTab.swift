import SwiftUI

/// ขั้น 1: Core Motion — อ่านการเคลื่อนไหว มุมเอียง ท่าแบบง่าย และ barometer
/// ใช้โค้ดใน SensorParts/Motion.swift ต้อง run บน iPad จริง (Simulator ไม่มี sensor)
struct MotionTab: View {
    private enum Page: Hashable { case motion, attitude, level, shakeMenu, stairs }

    var body: some View {
        NavigationStack {
            List {
                Section("ตัวอย่างใน handbook") {
                    NavigationLink(value: Page.motion) {
                        UseCaseRow(title: "MotionView", detail: "แรงเหวี่ยงแกน x, y, z · userAcceleration", icon: "arrow.left.and.right")
                    }
                    NavigationLink(value: Page.attitude) {
                        UseCaseRow(title: "AttitudeView", detail: "มุม pitch, roll, yaw · attitude", icon: "rotate.3d")
                    }
                }
                Section("Use case") {
                    NavigationLink(value: Page.level) {
                        UseCaseRow(title: "เอียงหรือไม่เอียง?", detail: "เช็กว่าโต๊ะเอียงไหม · attitude.roll", icon: "level")
                    }
                    NavigationLink(value: Page.shakeMenu) {
                        UseCaseRow(title: "เขย่าสุ่มเมนูมื้อเที่ยง", detail: "วันนี้กินอะไรดี · detectGesture", icon: "fork.knife")
                    }
                    NavigationLink(value: Page.stairs) {
                        UseCaseRow(title: "นับชั้นที่เดินขึ้นบันได", detail: "app ออกกำลังกาย · CMAltimeter", icon: "figure.stairs")
                    }
                }
                Section {
                    Text("Simulator ไม่มี sensor การเคลื่อนไหว ต้อง run บน iPad จริง")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Core Motion")
            // สร้างหน้าปลายทางตอนกดเท่านั้น (ถ้าเขียน NavigationLink { MotionView() } จะสร้างทุกหน้าตั้งแต่เปิด app)
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .motion: MotionView()
                case .attitude: AttitudeView()
                case .level: LevelView()
                case .shakeMenu: ShakeMenuView()
                case .stairs: StairsView()
                }
            }
        }
    }
}

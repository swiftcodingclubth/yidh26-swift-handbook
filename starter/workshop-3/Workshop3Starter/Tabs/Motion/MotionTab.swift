import SwiftUI

/// ขั้น 1: Core Motion — อ่านการเคลื่อนไหว มุมเอียง ท่าแบบง่าย และ barometer
/// ใช้โค้ดใน SensorParts/Motion.swift ต้อง run บน iPad จริง (Simulator ไม่มี sensor)
struct MotionTab: View {
    private enum Page: Hashable { case motion, attitude, gravity, rotation, level, shakeMenu, stairs, faceDown, flick, pickup, steering, wand, headsUp }

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
                    NavigationLink(value: Page.gravity) {
                        UseCaseRow(title: "GravityView", detail: "ทิศแรงโน้มถ่วง เครื่องอยู่ในท่าไหน · gravity", icon: "arrow.down.to.line")
                    }
                    NavigationLink(value: Page.rotation) {
                        UseCaseRow(title: "RotationView", detail: "ความเร็วการหมุนแกน x, y, z · rotationRate", icon: "arrow.trianglehead.2.clockwise.rotate.90")
                    }
                }
                Section("Use case: API เดียว") {
                    NavigationLink(value: Page.level) {
                        UseCaseRow(title: "เอียงหรือไม่เอียง?", detail: "เช็กว่าโต๊ะเอียงไหม · attitude.roll", icon: "level")
                    }
                    NavigationLink(value: Page.shakeMenu) {
                        UseCaseRow(title: "เขย่าสุ่มเมนูมื้อเที่ยง", detail: "วันนี้กินอะไรดี · detectGesture", icon: "fork.knife")
                    }
                    NavigationLink(value: Page.faceDown) {
                        UseCaseRow(title: "คว่ำเครื่องจับเวลา", detail: "คว่ำลงโต๊ะเพื่อจับเวลาอ่านหนังสือ · isFaceDown", icon: "book.closed")
                    }
                    NavigationLink(value: Page.flick) {
                        UseCaseRow(title: "บิดข้อมือเปลี่ยนสไลด์", detail: "ไม่ต้องแตะจอ · detectFlick", icon: "rectangle.stack")
                    }
                    NavigationLink(value: Page.stairs) {
                        UseCaseRow(title: "นับชั้นที่เดินขึ้นบันได", detail: "app ออกกำลังกาย · CMAltimeter (ต้องเดินขึ้นบันไดจริง)", icon: "figure.stairs")
                    }
                }
                Section("Use case: หลาย API รวมกัน") {
                    NavigationLink(value: Page.pickup) {
                        UseCaseRow(title: "เตือนเมื่อมีคนหยิบเครื่อง", detail: "userAcceleration + gravity · detectPickup", icon: "lock.shield")
                    }
                    NavigationLink(value: Page.steering) {
                        UseCaseRow(title: "พวงมาลัยเกมแข่งรถ", detail: "attitude + rotationRate", icon: "steeringwheel")
                    }
                    NavigationLink(value: Page.wand) {
                        UseCaseRow(title: "ไม้กายสิทธิ์", detail: "userAcceleration + rotationRate · detectSwing", icon: "wand.and.stars")
                    }
                }
                Section("Workshop: ลองเขียนเอง") {
                    NavigationLink(value: Page.headsUp) {
                        UseCaseRow(title: "เกมใบ้คำ", detail: "ก้มหน้า = ถูก เงยหน้า = ข้าม · เขียน detectTilt เอง", icon: "person.crop.square.badge.camera")
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
                Group {
                    switch page {
                    case .motion: MotionView()
                    case .attitude: AttitudeView()
                    case .gravity: GravityView()
                    case .rotation: RotationView()
                    case .level: LevelView()
                    case .shakeMenu: ShakeMenuView()
                    case .stairs: StairsView()
                    case .faceDown: FaceDownTimerView()
                    case .flick: FlickSlidesView()
                    case .pickup: PickupAlarmView()
                    case .steering: SteeringView()
                    case .wand: MagicWandView()
                    case .headsUp: HeadsUpView()
                    }
                }
                .toolbar(.hidden, for: .tabBar)   // ซ่อน tab bar เมื่อเข้าไปในแต่ละหน้า
            }
        }
    }
}

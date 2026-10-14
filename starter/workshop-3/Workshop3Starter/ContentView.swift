import SwiftUI

/// หน้าแรก: เลือก use case
/// แต่ละหน้าใช้แค่โค้ดจาก handbook: Motion.swift, Sound.swift, Lidar.swift และ Gesture.swift (Core ML)
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Core Motion · ตัวอย่างใน handbook") {
                    NavigationLink(value: Page.motion) {
                        UseCaseRow(title: "MotionView", detail: "แรงเหวี่ยงแกน x, y, z · userAcceleration", icon: "arrow.left.and.right")
                    }
                    NavigationLink(value: Page.attitude) {
                        UseCaseRow(title: "AttitudeView", detail: "มุม pitch, roll, yaw · attitude", icon: "rotate.3d")
                    }
                }
                Section("Core Motion · Use case") {
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
                Section("Sound · ตัวอย่างใน handbook") {
                    NavigationLink(value: Page.sound) {
                        UseCaseRow(title: "SoundView", detail: "เสียงที่มั่นใจที่สุดตอนนี้ · SoundListener", icon: "waveform")
                    }
                    NavigationLink(value: Page.knownSounds) {
                        UseCaseRow(title: "รายชื่อเสียงที่รู้จัก", detail: "ค้นหาชื่อเสียง · knownClassifications", icon: "list.bullet")
                    }
                }
                Section("Sound · Use case") {
                    NavigationLink(value: Page.soundAlert) {
                        UseCaseRow(title: "แจ้งเตือนเสียงสำคัญ", detail: "กริ่ง ควัน เด็กร้อง · เกณฑ์ความมั่นใจ", icon: "bell.badge")
                    }
                }
                Section("LiDAR · ตัวอย่างใน handbook") {
                    NavigationLink(value: Page.depth) {
                        UseCaseRow(title: "DepthView", detail: "ระยะของสิ่งที่อยู่กลางจอ · DepthReader", icon: "scope")
                    }
                }
                Section("LiDAR · Use case") {
                    NavigationLink(value: Page.obstacle) {
                        UseCaseRow(title: "เตือนสิ่งกีดขวาง", detail: "สำหรับผู้พิการทางสายตา · เปลี่ยนสีตามระยะ", icon: "figure.walk.motion")
                    }
                }
                Section("Core ML") {
                    NavigationLink(value: Page.predict) {
                        UseCaseRow(title: "GesturePredictor", detail: "ทำท่าแล้วบอกว่าทำท่าไหนอยู่ · GestureClassifier", icon: "brain")
                    }
                    NavigationLink(value: Page.imageClassify) {
                        UseCaseRow(title: "ในรูปมีอะไร?", detail: "model สำเร็จรูปจาก Apple ไม่ต้อง train · MobileNetV2", icon: "photo")
                    }
                }
                Section {
                    Text("Core Motion: Simulator ไม่มี sensor การเคลื่อนไหว ต้อง run บน iPad จริง")
                    Text("Sound: ลองบน Simulator ได้ จะใช้ไมโครโฟนของ Mac")
                    Text("LiDAR: มีเฉพาะ iPad Pro และ iPhone Pro ต้อง run บนเครื่องจริง")
                    Text("Core ML: GesturePredictor ต้อง run บน iPad จริง ส่วน \"ในรูปมีอะไร?\" ลองบน Simulator ได้")
                }
                .foregroundStyle(.secondary)
            }
            .navigationTitle("Workshop 3")
            // สร้างหน้าปลายทางตอนกดเท่านั้น หน้าแรกจึงเปิดเร็ว
            // (ถ้าเขียน NavigationLink { SoundView() } จะสร้างทุกหน้าพร้อมกันตั้งแต่เปิด app)
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .motion: MotionView()
                case .attitude: AttitudeView()
                case .level: LevelView()
                case .shakeMenu: ShakeMenuView()
                case .stairs: StairsView()
                case .sound: SoundView()
                case .knownSounds: KnownSoundsView()
                case .soundAlert: SoundAlertView()
                case .depth: DepthView()
                case .obstacle: ObstacleView()
                case .predict: PredictView()
                case .imageClassify: ImageClassifyView()
                }
            }
        }
    }
}

/// หน้าทั้งหมดที่เปิดได้จากหน้าแรก
private enum Page: Hashable {
    case motion, attitude, level, shakeMenu, stairs
    case sound, knownSounds, soundAlert
    case depth, obstacle
    case predict, imageClassify
}

private struct UseCaseRow: View {
    let title: String
    let detail: String
    let icon: String

    var body: some View {
        Label {
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: icon)
        }
    }
}

#Preview {
    ContentView()
}

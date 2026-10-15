import SwiftUI

/// ขั้น 2: Sound recognition — จดจำเสียงกว่า 300 แบบด้วย classifier ในตัว
/// ใช้โค้ดใน SensorParts/Sound.swift ลองบน Simulator ได้ (ใช้ไมโครโฟนของ Mac)
struct SoundTab: View {
    private enum Page: Hashable { case sound, knownSounds, soundAlert }

    var body: some View {
        NavigationStack {
            List {
                Section("ตัวอย่างใน handbook") {
                    NavigationLink(value: Page.sound) {
                        UseCaseRow(title: "SoundView", detail: "เสียงที่มั่นใจที่สุดตอนนี้ · SoundListener", icon: "waveform")
                    }
                    NavigationLink(value: Page.knownSounds) {
                        UseCaseRow(title: "รายชื่อเสียงที่รู้จัก", detail: "ค้นหาชื่อเสียง · knownClassifications", icon: "list.bullet")
                    }
                }
                Section("Use case") {
                    NavigationLink(value: Page.soundAlert) {
                        UseCaseRow(title: "แจ้งเตือนเสียงสำคัญ", detail: "กริ่ง ควัน เด็กร้อง · เกณฑ์ความมั่นใจ", icon: "bell.badge")
                    }
                }
                Section {
                    Text("ลองบน Simulator ได้ จะใช้ไมโครโฟนของ Mac")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Sound")
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .sound: SoundView()
                case .knownSounds: KnownSoundsView()
                case .soundAlert: SoundAlertView()
                }
            }
        }
    }
}

import SoundAnalysis
import SwiftUI

/// ตัวอย่างจากหน้า Sound recognition หัวข้อ "ดูรายชื่อเสียงที่รู้จัก"
/// ค้นหาชื่อเสียงที่ app ต้องใช้ แล้วเอาชื่อนั้นไปใส่ในโค้ด
/// หน้านี้ไม่ใช้ไมโครโฟน ลองบน Simulator ได้
struct KnownSoundsView: View {
    @State private var search = ""
    @State private var sounds: [String] = []

    var body: some View {
        List(filtered, id: \.self) { sound in
            Text(sound)
                .monospaced()
                .textSelection(.enabled)
        }
        .searchable(text: $search, prompt: "ค้นหา เช่น dog, bell, guitar")
        .navigationTitle("รู้จัก \(sounds.count) เสียง")
        .task {
            // โหลดรายชื่อตอนเปิดหน้านี้เท่านั้น การสร้าง request ต้องโหลด model เสียง ใช้เวลาพอสมควร
            let request = try? SNClassifySoundRequest(classifierIdentifier: .version1)
            sounds = request?.knownClassifications ?? []
        }
    }

    private var filtered: [String] {
        search.isEmpty ? sounds : sounds.filter { $0.localizedCaseInsensitiveContains(search) }
    }
}

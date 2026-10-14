import AVFoundation
import SwiftUI

/// ตัวอย่างจากหน้า Sound recognition: แสดงเสียงที่มั่นใจที่สุดตอนนี้
/// ลองพูด ปรบมือ เคาะโต๊ะ หรือเปิดเพลง แล้วดูว่า classifier ตอบว่าอะไร
struct SoundView: View {
    @State private var listener = SoundListener()
    @State private var sound = "–"
    @State private var confidence = 0.0
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Text(sound)
                .font(.system(size: 56, weight: .bold))
                .monospaced()
            ProgressView(value: confidence)
                .frame(width: 300)
            Text("ความมั่นใจ \(Int(confidence * 100))%")
                .font(.title2)
                .monospacedDigit()
            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
        }
        .navigationTitle("SoundView")
        .task {
            // ขออนุญาตใช้ไมโครโฟนก่อนเริ่มฟัง
            guard await AVAudioApplication.requestRecordPermission() else {
                errorMessage = "ไม่ได้รับอนุญาตให้ใช้ไมโครโฟน เปิดได้ใน Settings"
                return
            }
            listener.onResult = { newSound, newConfidence in
                sound = newSound
                confidence = newConfidence
            }
            do {
                try listener.start()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        .onDisappear { listener.stop() }   // ไมโครโฟนที่เปิดค้างกินแบตเตอรี่
    }
}

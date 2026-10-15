import AVFoundation
import SwiftUI

/// Use case: แจ้งเตือนเสียงสำคัญบนจอ สำหรับคนที่ได้ยินไม่ชัด หรือใส่หูฟังอยู่
/// ใช้วิธีจากหัวข้อ "ปรับให้แม่นขึ้น": รับเฉพาะเสียงที่สนใจ และมั่นใจเกิน 0.7
/// ลองเปิดคลิปเสียงกริ่งหรือเสียงเด็กร้องจากอีกเครื่องให้ iPad ฟัง
struct SoundAlertView: View {
    @State private var listener = SoundListener()
    @State private var alert: String?
    @State private var lastHeard = Date.distantPast
    @State private var errorMessage: String?

    // เสียงที่สนใจ: ชื่อที่ classifier ตอบ → ข้อความภาษาไทยที่แสดงให้ผู้ใช้เห็น
    private let important = [
        "smoke_detector": "🔥 เครื่องตรวจจับควันดัง",
        "door_bell": "🔔 มีคนกดกริ่ง",
        "baby_crying": "👶 เด็กร้อง",
    ]

    var body: some View {
        VStack(spacing: 24) {
            if let alert {
                Text(alert)
                    .font(.system(size: 56, weight: .bold))
                    .multilineTextAlignment(.center)
            } else {
                Image(systemName: "ear")
                    .font(.system(size: 80))
                Text("กำลังฟัง…")
                    .font(.title)
                Text("แจ้งเตือนเมื่อได้ยิน: เครื่องตรวจจับควัน, กริ่ง, เด็กร้อง")
                    .foregroundStyle(.secondary)
            }
            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(alert == nil ? Color.clear : Color.red.opacity(0.35))
        .animation(.easeInOut, value: alert)
        .navigationTitle("แจ้งเตือนเสียงสำคัญ")
        .task {
            guard await AVAudioApplication.requestRecordPermission() else {
                errorMessage = "ไม่ได้รับอนุญาตให้ใช้ไมโครโฟน เปิดได้ใน Settings"
                return
            }
            listener.onResult = { sound, confidence in
                if let message = important[sound], confidence > 0.7 {
                    alert = message
                    lastHeard = .now
                } else if Date.now.timeIntervalSince(lastHeard) > 3 {
                    alert = nil   // ค้างข้อความไว้ 3 วินาที จะได้อ่านทัน
                }
            }
            do {
                try listener.start()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        .onDisappear { listener.stop() }
    }
}

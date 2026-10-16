import CoreMotion
import SwiftUI

/// เฉลย Workshop: เกมใบ้คำ (Heads Up)
/// ไฟล์นี้อยู่นอก target จึงไม่ถูก compile ใช้เทียบกับ Tabs/Motion/HeadsUpView.swift
/// ถ้าจะใช้แทน ให้ copy ทั้งไฟล์ไปทับไฟล์เดิมใน starter

/// ท่าของศีรษะตอนถือเครื่องแปะหน้าผาก
enum HeadTilt { case down, up, upright }

/// TODO: จับท่าจาก gravity.z
/// แกน z ชี้ออกจากจอ ถือแปะหน้าผากตั้งตรง z ≈ 0 · ก้มหน้า จอหันลงพื้น z → +1 · เงยหน้า จอหันขึ้นเพดาน z → -1
/// เว้นช่วงกลาง (0.3 ถึง 0.7) ไว้ไม่ให้เป็นท่าไหน กันค่าแกว่งไปมาตรงเส้นเกณฑ์
func detectTilt(_ data: CMDeviceMotion) -> HeadTilt? {
    let z = data.gravity.z
    if z > 0.7 { return .down }
    if z < -0.7 { return .up }
    if abs(z) < 0.3 { return .upright }
    return nil
}

struct HeadsUpView: View {
    @State private var words = HeadsUpView.allWords.shuffled()
    @State private var index = 0
    @State private var score = 0
    @State private var skipped = 0
    @State private var flash = Color.clear
    @State private var waitingUpright = false   // นับแล้ว รอกลับมาตั้งตรงก่อน

    var body: some View {
        VStack(spacing: 24) {
            Text(words[index])
                .font(.system(size: 120, weight: .heavy))
                .minimumScaleFactor(0.3)
                .lineLimit(1)
            HStack(spacing: 40) {
                Label("\(score)", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                Label("\(skipped)", systemImage: "forward.fill").foregroundStyle(.orange)
            }
            .font(.largeTitle.bold())
            .monospacedDigit()
            Text("ก้มหน้า = ถูก · เงยหน้า = ข้าม")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(flash.opacity(0.4))
        .navigationTitle("เกมใบ้คำ")
        .onAppear {
            startMotionUpdates { data in
                guard let tilt = detectTilt(data) else { return }

                // นับไปแล้ว ไม่สนท่าอื่นจนกว่าจะกลับมาตั้งตรง ไม่อย่างนั้นก้มครั้งเดียวจะข้ามหลายคำ
                if waitingUpright {
                    if tilt == .upright { waitingUpright = false }
                    return
                }

                // ก้มหน้า = ถูก · เงยหน้า = ข้าม
                switch tilt {
                case .down:
                    correct()
                    waitingUpright = true
                case .up:
                    skip()
                    waitingUpright = true
                case .upright:
                    break
                }
            }
        }
        .onDisappear { stopMotionUpdates() }
    }

    // MARK: - ทำไว้ให้แล้ว

    /// ตอบถูก: ได้คะแนน แล้วไปคำถัดไป
    private func correct() {
        score += 1
        next(color: .green)
    }

    /// ข้าม: ไม่ได้คะแนน แล้วไปคำถัดไป
    private func skip() {
        skipped += 1
        next(color: .orange)
    }

    private func next(color: Color) {
        flash = color
        withAnimation(.easeOut(duration: 0.6)) { flash = .clear }
        index += 1
        if index == words.count {   // หมดคำแล้ว สับใหม่
            words.shuffle()
            index = 0
        }
    }

    private static let allWords = [
        "ช้าง", "ส้มตำ", "ตุ๊กตุ๊ก", "ทุเรียน", "ฟุตบอล", "หมอฟัน", "ไอศกรีม", "กีตาร์",
        "เครื่องบิน", "ยีราฟ", "ร่ม", "นาฬิกา", "สงกรานต์", "ชานมไข่มุก", "ซูเปอร์แมน", "หมีแพนด้า",
    ]
}

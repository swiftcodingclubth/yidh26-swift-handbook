import CoreMotion
import SwiftUI

/// Workshop: เกมใบ้คำ (Heads Up)
/// ถือ iPad แนวนอนแปะหน้าผาก จอหันออกให้เพื่อนเห็นคำ เพื่อนใบ้ แล้ว ก้มหน้า = ถูก เงยหน้า = ข้าม
/// เกมทำไว้ให้หมดแล้ว เขียนเฉพาะ detectTilt (TODO) เฉลยอยู่ใน starter/workshop-3/Solutions/HeadsUpView.swift

/// ท่าของศีรษะตอนถือเครื่องแปะหน้าผาก
enum HeadTilt { case down, up, upright }

/// TODO: เปลี่ยน nil ใน 3 บรรทัดแรกเป็นท่าที่ถูกต้อง
/// เปิด GravityView ถือเครื่องแปะหน้าผาก แล้วดูค่า z ตอนตั้งตรง ก้มหน้า และเงยหน้า
/// ก้มหน้า (จอหันลงพื้น) → .down · เงยหน้า (จอหันขึ้นเพดาน) → .up · ตั้งตรง → .upright · อยู่ระหว่างกลาง → nil
func detectTilt(_ data: CMDeviceMotion) -> HeadTilt? {
    let z = data.gravity.z
    if z > 0.7 { return nil }
    if z < -0.7 { return nil }
    if z < 0.3 && z > -0.3 { return nil }
    return nil   // ตอนนี้ยังไม่รู้จักท่าไหนเลย เกมจึงยังไม่ขยับ
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

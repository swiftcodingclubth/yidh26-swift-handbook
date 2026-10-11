import CoreImage
import SwiftUI
import Vision

// MARK: - 1. หามือในภาพ

/// หามือ 1 มือในภาพ ถ้าไม่เจอได้ `nil`
func findHand(in frame: CVPixelBuffer) async -> HumanHandPoseObservation? {
    var request = DetectHumanHandPoseRequest()
    request.maximumHandCount = 1
    // ห่อเป็น CIImage ก่อนส่ง เพื่อให้ใช้ได้ทั้ง Swift 5 และ Swift 6
    return try? await request.perform(on: CIImage(cvPixelBuffer: frame)).first
}

// MARK: - 3. แปลงเป็นท่า

extension HumanHandPoseObservation {
    /// จำนวนนิ้วที่เหยียดอยู่ ไม่นับนิ้วโป้ง
    /// นิ้วเหยียด = ปลายนิ้วอยู่ไกลข้อมือมากกว่าข้อกลางนิ้ว
    var extendedFingerCount: Int {
        guard let wrist = joint(for: .wrist) else { return 0 }
        let fingers: [(tip: JointName, pip: JointName)] = [
            (.indexTip, .indexPIP), (.middleTip, .middlePIP),
            (.ringTip, .ringPIP), (.littleTip, .littlePIP),
        ]
        return fingers.filter { finger in
            guard let tip = joint(for: finger.tip), let pip = joint(for: finger.pip),
                  tip.confidence > 0.3, pip.confidence > 0.3 else { return false }
            return tip.distance(to: wrist) > pip.distance(to: wrist)
        }.count
    }
}

enum HandSign: String, CaseIterable {
    case rock = "✊", scissors = "✌️", paper = "✋", unknown = "❓"

    init(fingers: Int) {
        switch fingers {
        case 0: self = .rock
        case 2: self = .scissors
        case 4: self = .paper
        default: self = .unknown
        }
    }
}

// MARK: - 2 และ 4. ส่งผลให้ UI และทำให้ผลนิ่ง

@MainActor @Observable
final class HandModel {
    /// ตำแหน่งข้อนิ้วแบบ 0–1 โดยมุมบนซ้ายเป็น (0, 0) แบบ SwiftUI
    var points: [CGPoint] = []
    /// ท่าล่าสุดที่นิ่งแล้ว
    var sign: HandSign = .unknown

    private var isBusy = false
    private var lastSign: HandSign = .unknown
    private var sameCount = 0

    func handle(_ frame: CVPixelBuffer) {
        guard !isBusy else { return }   // frame เก่ายังไม่เสร็จ ข้ามไปก่อน
        isBusy = true
        Task {
            defer { isBusy = false }
            guard let hand = await findHand(in: frame) else {
                points = []
                update(with: .unknown)
                return
            }
            points = hand.allJoints().values
                .filter { $0.confidence > 0.3 }
                .map { CGPoint(x: $0.location.x, y: 1 - $0.location.y) }   // Vision: (0, 0) อยู่มุมล่างซ้าย
            update(with: HandSign(fingers: hand.extendedFingerCount))
        }
    }

    /// เปลี่ยนท่าเมื่อได้ท่าเดิมติดกัน 5 frame เพื่อไม่ให้กะพริบ
    private func update(with newSign: HandSign) {
        sameCount = (newSign == lastSign) ? sameCount + 1 : 0
        lastSign = newSign
        if sameCount >= 5 { sign = newSign }
    }
}

/// วาดจุดข้อนิ้ว ใช้เป็น overlay ของ `CameraView`
struct HandPointsOverlay: View {
    var points: [CGPoint]

    var body: some View {
        GeometryReader { geo in
            ForEach(points.indices, id: \.self) { i in
                Circle()
                    .fill(.yellow)
                    .frame(width: 14, height: 14)
                    .position(x: points[i].x * geo.size.width, y: points[i].y * geo.size.height)
            }
        }
        .allowsHitTesting(false)
    }
}

import SwiftUI

/// กรอบรอบวัตถุแต่ละชิ้น วางทับบนรูปหรือภาพจากกล้องที่มีขนาดเท่ากัน
/// ใช้ร่วมกันในหน้า "หาวัตถุในรูป" และ "หาวัตถุแบบ live"
struct ObjectBoxes: View {
    let objects: [DetectedObject]

    var body: some View {
        GeometryReader { geo in
            ForEach(objects) { object in
                // box เป็นสัดส่วน 0–1 คูณกับขนาดของภาพที่แสดงอยู่
                let rect = CGRect(x: object.box.minX * geo.size.width,
                                  y: object.box.minY * geo.size.height,
                                  width: object.box.width * geo.size.width,
                                  height: object.box.height * geo.size.height)
                Rectangle()
                    .stroke(.yellow, lineWidth: 3)
                    .frame(width: rect.width, height: rect.height)
                    .overlay(alignment: .topLeading) {
                        Text("\(object.label) \(Int(object.confidence * 100))%")
                            .font(.caption.bold())
                            .padding(4)
                            .background(.yellow)
                            .foregroundStyle(.black)
                    }
                    .position(x: rect.midX, y: rect.midY)
            }
        }
        .allowsHitTesting(false)
    }
}

/// สรุปจำนวนแต่ละชนิด เช่น "เจอ 3 ชิ้น: dog × 2, person × 1"
func objectSummary(_ objects: [DetectedObject]) -> String {
    guard !objects.isEmpty else { return "ไม่เจอวัตถุที่ model รู้จัก" }
    let counts = Dictionary(objects.map { ($0.label, 1) }, uniquingKeysWith: +)
    let text = counts.sorted { $0.key < $1.key }.map { "\($0.key) × \($0.value)" }.joined(separator: ", ")
    return "เจอ \(objects.count) ชิ้น: \(text)"
}

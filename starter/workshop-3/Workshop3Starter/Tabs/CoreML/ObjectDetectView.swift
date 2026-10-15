import PhotosUI
import SwiftUI

/// ตัวอย่างจากหน้า Core ML หัวข้อ "หาวัตถุในรูปด้วย YOLOv3"
/// เลือกรูปจาก Photos แล้ว YOLOv3 ตีกรอบวัตถุทุกชิ้นที่เจอ พร้อมชื่อและจำนวน
/// ใช้รูปถ่ายทั่วไปที่มีหลายอย่างในฉาก เช่น คนกับสุนัข โต๊ะอาหาร ถนน จะได้ผลดีกว่ารูปถ่ายใกล้ของชิ้นเดียว
/// ลองบน Simulator ได้ (ลากรูปไปวางบน Simulator เพื่อเพิ่มเข้า Photos)
struct ObjectDetectView: View {
    @State private var detector = ObjectDetector()
    @State private var item: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var objects: [DetectedObject] = []
    @State private var message = "เลือกรูปที่มีคน สัตว์ หรือสิ่งของหลายอย่าง"

    var body: some View {
        VStack(spacing: 20) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay { boxes }
                    .frame(maxHeight: 500)
            }
            Text(message)
                .font(.title2)
            PhotosPicker("เลือกรูป", selection: $item, matching: .images)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("หาวัตถุในรูป")
        .onChange(of: item) {
            Task {
                guard let data = try? await item?.loadTransferable(type: Data.self),
                      let picked = UIImage(data: data) else { return }
                image = picked
                objects = (try? await detector.detect(in: picked)) ?? []
                message = summary
            }
        }
    }

    /// กรอบรอบวัตถุแต่ละชิ้น วางทับบนรูป
    private var boxes: some View {
        GeometryReader { geo in
            ForEach(objects) { object in
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
    }

    /// สรุปจำนวนแต่ละชนิด เช่น "เจอ 3 ชิ้น: person × 1, dog × 2"
    private var summary: String {
        guard !objects.isEmpty else { return "ไม่เจอวัตถุที่ model รู้จัก ลองรูปอื่น" }
        let counts = Dictionary(objects.map { ($0.label, 1) }, uniquingKeysWith: +)
        let text = counts.sorted { $0.key < $1.key }.map { "\($0.key) × \($0.value)" }.joined(separator: ", ")
        return "เจอ \(objects.count) ชิ้น: \(text)"
    }
}

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
                    .overlay { ObjectBoxes(objects: objects) }
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
                message = objects.isEmpty ? "ไม่เจอวัตถุที่ model รู้จัก ลองรูปอื่น" : objectSummary(objects)
            }
        }
    }
}

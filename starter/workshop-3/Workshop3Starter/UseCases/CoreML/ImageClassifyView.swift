import PhotosUI
import SwiftUI

/// ตัวอย่างจากหน้า Core ML หัวข้อ "ใช้ model สำเร็จรูปจาก Apple"
/// เลือกรูปจาก Photos แล้ว model บอกว่าในรูปมีอะไร ไม่ต้อง train เอง
/// ลองบน Simulator ได้ (ลากรูปไปวางบน Simulator เพื่อเพิ่มเข้า Photos)
struct ImageClassifyView: View {
    @State private var classifier = ImageClassifier()
    @State private var item: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var label = "–"
    @State private var confidence = 0.0

    var body: some View {
        VStack(spacing: 24) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .clipShape(.rect(cornerRadius: 16))
            }
            Text(label)
                .font(.system(size: 48, weight: .bold))
            ProgressView(value: confidence)
                .frame(width: 300)
            Text("ความมั่นใจ \(Int(confidence * 100))%")
                .font(.title2)
                .monospacedDigit()
            PhotosPicker("เลือกรูป", selection: $item, matching: .images)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("ในรูปมีอะไร?")
        .onChange(of: item) {
            Task {
                guard let data = try? await item?.loadTransferable(type: Data.self),
                      let picked = UIImage(data: data) else { return }
                image = picked
                if let result = try? classifier.classify(picked) {
                    label = result.label
                    confidence = result.confidence
                }
            }
        }
    }
}

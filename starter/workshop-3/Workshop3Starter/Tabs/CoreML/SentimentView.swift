import SwiftUI

/// Use case: ข้อความนี้บวกหรือลบ ด้วย model ที่อยู่ใน iOS แล้ว
/// ใช้ sentimentScore จาก handbook พิมพ์เป็นภาษาอังกฤษ ลองเทียบกับหน้า "วันนี้รู้สึกอย่างไร" ที่ใช้ model ที่ train เอง
struct SentimentView: View {
    @State private var text = "the food was great but the service was slow"
    @State private var score: Double?

    var body: some View {
        VStack(spacing: 28) {
            Text(face)
                .font(.system(size: 120))
            if let score {
                Text(String(format: "%+.2f", score))
                    .font(.system(size: 48, weight: .bold))
                    .monospacedDigit()
                HStack {
                    Text("ลบ")
                    ProgressView(value: (score + 1) / 2)   // -1…1 เป็น 0…1
                        .tint(score >= 0 ? .green : .red)
                    Text("บวก")
                }
                .frame(maxWidth: 500)
            }
            TextField("พิมพ์ข้อความภาษาอังกฤษ", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.asciiCapable)
                .frame(maxWidth: 600)
            Text("Model นี้ตอบได้แค่บวกหรือลบ ส่วน EmotionClassifier ที่ train เองแยกได้ 6 อารมณ์")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .navigationTitle("ข้อความบวกหรือลบ")
        .onAppear { score = sentimentScore(of: text) }
        .onChange(of: text) { score = sentimentScore(of: text) }
    }

    private var face: String {
        guard let score else { return "🤔" }
        if score > 0.3 { return "😀" }
        if score < -0.3 { return "☹️" }
        return "😐"
    }
}

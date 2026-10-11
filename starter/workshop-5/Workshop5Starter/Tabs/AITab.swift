import FoundationModels
import PhotosUI
import SwiftUI
import Vision
import VisionKit

/// ไปต่อ (iOS 27): ส่งรูปให้ Foundation Models โดยให้ model เรียก OCR และอ่าน barcode ของ Vision เอง
/// ต้อง build ด้วย Xcode 27 และ run บน iPad ที่เปิด Apple Intelligence
struct AITab: View {
    var body: some View {
        #if compiler(>=6.4)
        if #available(iOS 27, *) {
            ImagePromptScreen()
        } else {
            ContentUnavailableView("ต้องใช้ iPadOS 27", systemImage: "sparkles")
        }
        #else
        ContentUnavailableView("ต้อง build ด้วย Xcode 27", systemImage: "sparkles",
            description: Text("แท็บนี้ใช้ API ของ iOS 27"))
        #endif
    }
}

#if compiler(>=6.4)
@available(iOS 27, *)
private struct ImagePromptScreen: View {
    @State private var item: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var prompt = "สรุปใบเสร็จนี้: ร้านอะไร ซื้ออะไรบ้าง รวมเท่าไร"
    @State private var answer = ""
    @State private var isThinking = false
    @State private var showDocumentScanner = false

    private let model = SystemLanguageModel.default

    var body: some View {
        NavigationStack {
            Form {
                Section("สถานะ model") {
                    Text(status)
                }
                Section("รูป") {
                    if let image {
                        Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 240)
                    }
                    PhotosPicker("เลือกรูปจาก Photos", selection: $item, matching: .images)
                    Button("Scan เอกสาร") { showDocumentScanner = true }
                        .disabled(!VNDocumentCameraViewController.isSupported)
                }
                Section("คำถาม") {
                    TextField("ถามอะไรเกี่ยวกับรูปนี้", text: $prompt, axis: .vertical)
                    Button(isThinking ? "กำลังคิด…" : "ถาม AI") { Task { await ask() } }
                        .disabled(image == nil || isThinking || !canUseImages)
                }
                if !answer.isEmpty {
                    Section("คำตอบ") {
                        Text(answer).textSelection(.enabled)
                    }
                }
            }
            .navigationTitle("AI ดูรูป")
            .onChange(of: item) {
                Task {
                    guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
                    image = UIImage(data: data)
                    answer = ""
                }
            }
            .fullScreenCover(isPresented: $showDocumentScanner) {
                DocumentScannerView { pages in
                    if let first = pages.first {
                        image = first
                        answer = ""
                    }
                    showDocumentScanner = false
                }
                .ignoresSafeArea()
            }
        }
    }

    private var canUseImages: Bool {
        model.availability == .available && model.capabilities.contains(.vision)
    }

    private var status: String {
        switch model.availability {
        case .available:
            model.capabilities.contains(.vision)
                ? "✅ พร้อมใช้ และรับรูปได้"
                : "❌ model พร้อมใช้ แต่เครื่องนี้ส่งรูปให้ไม่ได้"
        case .unavailable(let reason):
            "❌ ใช้ไม่ได้: \(reason)"
        }
    }

    private func ask() async {
        guard let cgImage = image?.cgImage, let image else { return }
        isThinking = true
        defer { isThinking = false }
        do {
            // ให้ model เรียกใช้ OCR และอ่าน barcode ของ Vision เองเมื่อจำเป็น
            let session = LanguageModelSession(model: model, tools: [OCRTool(), BarcodeReaderTool()])
            // ต้องตั้ง label ให้รูป และบอก model ว่ารูปชื่ออะไร
            // ไม่อย่างนั้น model จะเดาชื่อรูปเอง แล้ว OCRTool หารูปไม่เจอ
            let response = try await session.respond {
                "\(prompt)\n(รูปที่แนบมีชื่อว่า receipt)"
                Attachment(cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
                    .label("receipt")
            }
            answer = response.content
        } catch {
            answer = "เกิดข้อผิดพลาด: \(error)"
        }
    }
}
#endif

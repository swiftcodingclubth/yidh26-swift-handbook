import PhotosUI
import SwiftUI
import VisionKit

/// ขั้น 2: Vision — อ่านข้อความจากรูปใน Photos หรือจากเอกสารที่ scan
/// ส่วนเลือกรูปลองบน Simulator ได้ (ลากรูปไปวางบน Simulator เพื่อเพิ่มเข้า Photos)
struct ReadTab: View {
    @State private var item: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var lines: [String] = []
    @State private var isReading = false
    @State private var errorMessage: String?
    @State private var showDocumentScanner = false

    var body: some View {
        NavigationStack {
            List {
                if let image {
                    Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 240)
                }
                Section(isReading ? "กำลังอ่าน…" : "ข้อความที่อ่านได้ · \(lines.count) บรรทัด") {
                    ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                        Text(line).textSelection(.enabled)
                    }
                }
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
            .navigationTitle("Read")
            .toolbar {
                PhotosPicker(selection: $item, matching: .images) {
                    Label("เลือกรูป", systemImage: "photo")
                }
                Button("Scan เอกสาร", systemImage: "doc.viewfinder") { showDocumentScanner = true }
                    .disabled(!VNDocumentCameraViewController.isSupported)
            }
            .onChange(of: item) {
                Task {
                    guard let data = try? await item?.loadTransferable(type: Data.self),
                          let picked = UIImage(data: data) else { return }
                    await read([picked])
                }
            }
            .fullScreenCover(isPresented: $showDocumentScanner) {
                DocumentScannerView { pages in
                    showDocumentScanner = false
                    Task { await read(pages) }
                }
                .ignoresSafeArea()
            }
        }
    }

    private func read(_ images: [UIImage]) async {
        guard let first = images.first else { return }
        image = first
        isReading = true
        errorMessage = nil
        defer { isReading = false }
        do {
            var all: [String] = []
            for page in images {
                all += try await readText(from: page)
            }
            lines = all
        } catch {
            lines = []
            errorMessage = "อ่านไม่สำเร็จ: \(error.localizedDescription)"
        }
    }
}

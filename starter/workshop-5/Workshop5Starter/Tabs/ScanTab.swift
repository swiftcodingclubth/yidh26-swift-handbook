import AVFoundation
import SwiftUI
import VisionKit

/// ขั้น 1: VisionKit — scan ข้อความและ QR สด และ scan เอกสาร
struct ScanTab: View {
    @State private var cameraAllowed: Bool?
    @State private var results: [String] = []
    @State private var pages: [UIImage] = []
    @State private var showDocumentScanner = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                scanner
                    .frame(maxHeight: .infinity)
                List {
                    Section("แตะข้อความหรือ QR บนจอ") {
                        ForEach(Array(results.enumerated().reversed()), id: \.offset) { _, text in
                            Text(text).textSelection(.enabled)
                        }
                    }
                    if !pages.isEmpty {
                        Section("เอกสารที่ scan · \(pages.count) หน้า") {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(pages.indices, id: \.self) { i in
                                        Image(uiImage: pages[i]).resizable().scaledToFit().frame(height: 120)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 280)
            }
            .navigationTitle("Scan")
            .toolbar {
                Button("Scan เอกสาร", systemImage: "doc.viewfinder") { showDocumentScanner = true }
                    .disabled(!VNDocumentCameraViewController.isSupported)
            }
            .fullScreenCover(isPresented: $showDocumentScanner) {
                DocumentScannerView { scanned in
                    if !scanned.isEmpty { pages = scanned }
                    showDocumentScanner = false
                }
                .ignoresSafeArea()
            }
            .task {
                cameraAllowed = await AVCaptureDevice.requestAccess(for: .video)
            }
        }
    }

    @ViewBuilder private var scanner: some View {
        if !DataScannerViewController.isSupported {
            ContentUnavailableView("เครื่องนี้ scan สดไม่ได้", systemImage: "camera.slash",
                description: Text("Simulator ไม่มีกล้อง ให้ run บน iPad"))
        } else if cameraAllowed == false || (cameraAllowed == true && !DataScannerViewController.isAvailable) {
            ContentUnavailableView("ไม่ได้รับสิทธิ์กล้อง", systemImage: "camera.slash",
                description: Text("เปิดได้ที่ Settings → ชื่อ app → Camera"))
        } else if cameraAllowed == true {
            LiveScannerView { text in results.append(text) }
        } else {
            ProgressView()
        }
    }
}

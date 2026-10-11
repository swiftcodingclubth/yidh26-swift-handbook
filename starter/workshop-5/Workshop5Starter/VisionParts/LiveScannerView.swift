import SwiftUI
import VisionKit

/// หน้าจอ scan สดของ VisionKit: แสดงกรอบรอบข้อความและ QR code ที่เจอ
/// เมื่อผู้ใช้แตะ จะส่งข้อความนั้นให้ `onTap`
///
/// ก่อนแสดง ให้เช็ก `DataScannerViewController.isSupported` และขอสิทธิ์กล้องก่อน
/// ต้องมี `NSCameraUsageDescription` ใน Info.plist
struct LiveScannerView: View {
    var onTap: (String) -> Void

    @State private var isVisible = false

    var body: some View {
        DataScannerRepresentable(isScanning: isVisible, onTap: onTap)
            // TabView ไม่ทำลายแท็บที่ซ่อนอยู่ จึงต้องหยุดและเริ่ม scan เอง
            // ไม่อย่างนั้นสลับแท็บแล้วกลับมาจะ scan ไม่ติด
            .onAppear { isVisible = true }
            .onDisappear { isVisible = false }
    }
}

private struct DataScannerRepresentable: UIViewControllerRepresentable {
    var isScanning: Bool
    var onTap: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text(languages: ["th-TH", "en-US"]), .barcode()],
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ scanner: DataScannerViewController, context: Context) {
        context.coordinator.onTap = onTap
        if isScanning {
            if !scanner.isScanning { try? scanner.startScanning() }
        } else if scanner.isScanning {
            scanner.stopScanning()
        }
    }

    static func dismantleUIViewController(_ scanner: DataScannerViewController, coordinator: Coordinator) {
        scanner.stopScanning()
    }

    func makeCoordinator() -> Coordinator { Coordinator(onTap: onTap) }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var onTap: (String) -> Void
        init(onTap: @escaping (String) -> Void) { self.onTap = onTap }

        func dataScanner(_ scanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text): onTap(text.transcript)
            case .barcode(let code): onTap(code.payloadStringValue ?? "")
            @unknown default: break
            }
        }
    }
}

import SwiftUI
import Vision
import VisionKit

/// สำหรับผู้สอน: เช็กว่าเครื่องนี้อ่านภาษาไทยได้ไหม ก่อนวันสอน
struct LanguagesTab: View {
    private let visionLanguages: [String] = {
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        return request.supportedRecognitionLanguages.map(\.maximalIdentifier)
    }()

    private let scannerLanguages = DataScannerViewController.supportedTextRecognitionLanguages

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(visionLanguages, id: \.self) { Text($0) }
                } header: {
                    Text("Vision · RecognizeTextRequest (.accurate)")
                } footer: {
                    thaiStatus(visionLanguages)
                }
                Section {
                    ForEach(scannerLanguages, id: \.self) { Text($0) }
                } header: {
                    Text("VisionKit · DataScannerViewController")
                } footer: {
                    thaiStatus(scannerLanguages)
                }
            }
            .navigationTitle("ภาษาที่รองรับ")
        }
    }

    private func thaiStatus(_ languages: [String]) -> some View {
        let hasThai = languages.contains { $0.hasPrefix("th") }
        return Text(hasThai ? "✅ อ่านภาษาไทยได้" : "❌ ไม่มีภาษาไทย")
            .font(.headline)
    }
}

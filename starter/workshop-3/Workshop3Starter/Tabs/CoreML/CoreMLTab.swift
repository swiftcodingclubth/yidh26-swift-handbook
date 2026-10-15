import SwiftUI

/// ขั้น 4: Core ML — run model ใน app ทั้ง model ที่ train เองและ model สำเร็จรูปจาก Apple
/// ใช้โค้ดใน SensorParts/Gesture.swift และ SensorParts/ImageClassifier.swift
struct CoreMLTab: View {
    private enum Page: Hashable { case predict, imageClassify }

    var body: some View {
        NavigationStack {
            List {
                Section("Model ที่ train เองใน Create ML") {
                    NavigationLink(value: Page.predict) {
                        UseCaseRow(title: "GesturePredictor", detail: "กดเริ่ม ทำท่า กดหยุด แล้วทายว่าเป็นท่าอะไร · GestureClassifier", icon: "brain")
                    }
                }
                Section("Model สำเร็จรูปจาก Apple") {
                    NavigationLink(value: Page.imageClassify) {
                        UseCaseRow(title: "ในรูปมีอะไร?", detail: "ไม่ต้อง train · MobileNetV2", icon: "photo")
                    }
                }
                Section {
                    Text("GesturePredictor ต้อง run บน iPad จริง ส่วน \"ในรูปมีอะไร?\" ลองบน Simulator ได้")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Core ML")
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .predict: PredictView()
                case .imageClassify: ImageClassifyView()
                }
            }
        }
    }
}

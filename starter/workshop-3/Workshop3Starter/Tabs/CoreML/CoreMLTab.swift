import SwiftUI

/// ขั้น 4: Core ML — run model ใน app ทั้ง model ที่ train เองและ model สำเร็จรูปจาก Apple
/// ใช้โค้ดใน SensorParts/TextEmotion.swift, ImageClassifier.swift และ ObjectDetector.swift
struct CoreMLTab: View {
    private enum Page: Hashable { case mood, imageClassify, objectDetect }

    var body: some View {
        NavigationStack {
            List {
                Section("Model ที่ train เองใน Create ML") {
                    NavigationLink(value: Page.mood) {
                        UseCaseRow(title: "วันนี้รู้สึกอย่างไร", detail: "พิมพ์แล้ว emoji และสีเปลี่ยนตามอารมณ์ · EmotionClassifier", icon: "face.smiling")
                    }
                }
                Section("Model สำเร็จรูปจาก Apple") {
                    NavigationLink(value: Page.imageClassify) {
                        UseCaseRow(title: "ในรูปมีอะไร?", detail: "ไม่ต้อง train · MobileNetV2", icon: "photo")
                    }
                    NavigationLink(value: Page.objectDetect) {
                        UseCaseRow(title: "หาวัตถุในรูป", detail: "ตีกรอบวัตถุทุกชิ้นที่เจอ · YOLOv3", icon: "viewfinder")
                    }
                }
                Section {
                    Text("ลองบน Simulator ได้ทุกหน้า")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Core ML")
            .navigationDestination(for: Page.self) { page in
                Group {
                    switch page {
                    case .mood: MoodView()
                    case .imageClassify: ImageClassifyView()
                    case .objectDetect: ObjectDetectView()
                    }
                }
                .toolbar(.hidden, for: .tabBar)   // ซ่อน tab bar เมื่อเข้าไปในแต่ละหน้า
            }
        }
    }
}

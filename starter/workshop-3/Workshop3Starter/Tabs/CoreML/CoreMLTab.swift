import SwiftUI

/// ขั้น 4: Core ML — run model ใน app ทั้ง model ที่ train เองและ model สำเร็จรูปจาก Apple
/// ใช้โค้ดใน MLParts/TextEmotion.swift, ImageClassifier.swift, ObjectDetector.swift และ CameraView.swift
struct CoreMLTab: View {
    private enum Page: Hashable { case inspector, mood, imageClassify, objectDetect, liveDetect, sentiment, community, desk }

    var body: some View {
        NavigationStack {
            List {
                Section("Concept") {
                    NavigationLink(value: Page.inspector) {
                        UseCaseRow(title: "ข้างใน model", detail: "input, output และป้ายของทุก model · modelDescription", icon: "doc.text.magnifyingglass")
                    }
                }
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
                    NavigationLink(value: Page.liveDetect) {
                        UseCaseRow(title: "หาวัตถุแบบ live", detail: "หันกล้องไปที่ไหนก็ตีกรอบให้ทันที · YOLOv3 + กล้อง", icon: "camera.viewfinder")
                    }
                    NavigationLink(value: Page.sentiment) {
                        UseCaseRow(title: "ข้อความบวกหรือลบ", detail: "model ที่อยู่ใน iOS แล้ว ไม่ต้องดาวน์โหลด · NLTagger", icon: "text.bubble")
                    }
                }
                Section("Model ของคนอื่น") {
                    NavigationLink(value: Page.community) {
                        UseCaseRow(title: "ใช้ model ของคนอื่น", detail: "image classifier ตัวไหนก็ได้ ทั้งรูปและกล้องสด · AnyImageClassifier", icon: "shippingbox")
                    }
                }
                Section("Workshop: ลองเขียนเอง") {
                    NavigationLink(value: Page.desk) {
                        UseCaseRow(title: "ของบนโต๊ะคืออะไร", detail: "MobileNetV2 ของ Apple กับกล้องสด บอกเป็นภาษาไทย", icon: "camera.macro")
                    }
                }
                Section {
                    Text("ลองบน Simulator ได้ ยกเว้นหน้าที่ใช้กล้องสด ซึ่งต้องใช้กล้องของ iPad")
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
                    case .liveDetect: LiveDetectView()
                    case .inspector: ModelInspectorView()
                    case .sentiment: SentimentView()
                    case .community: AnyModelView(modelName: "CommunityClassifier", title: "ใช้ model ของคนอื่น")
                    case .desk: DeskClassifierView()
                    }
                }
                .toolbar(.hidden, for: .tabBar)   // ซ่อน tab bar เมื่อเข้าไปในแต่ละหน้า
            }
        }
    }
}

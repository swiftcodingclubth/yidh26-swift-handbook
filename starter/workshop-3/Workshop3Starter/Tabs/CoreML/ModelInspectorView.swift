import CoreML
import SwiftUI

/// Concept: ข้างใน model มีอะไร
/// ทุก model บอกได้ว่ารับ input อะไร ให้ output อะไร และตอบป้ายอะไรได้บ้าง
/// อ่านจาก modelDescription แบบเดียวกับแท็บ Predictions ใน Xcode เป็นสิ่งแรกที่ต้องดูเมื่อได้ model ใหม่มา
struct ModelInspectorView: View {
    private struct Entry: Identifiable {
        let id: String       // ชื่อ model
        let source: String   // มาจากไหน
        let callWith: String // เรียกใช้แบบไหน
        let model: MLModel?
    }

    @State private var entries: [Entry] = []

    var body: some View {
        List(entries) { entry in
            Section {
                LabeledContent("มาจาก", value: entry.source)
                LabeledContent("เรียกใช้ผ่าน", value: entry.callWith)
                if let description = entry.model?.modelDescription {
                    ForEach(features(description.inputDescriptionsByName), id: \.self) { line in
                        LabeledContent("Input", value: line)
                    }
                    ForEach(features(description.outputDescriptionsByName), id: \.self) { line in
                        LabeledContent("Output", value: line)
                    }
                    let labels = description.classLabels?.map { "\($0)" } ?? []
                    if !labels.isEmpty {
                        LabeledContent("ป้าย \(labels.count) แบบ", value: labels.prefix(6).joined(separator: ", ") + (labels.count > 6 ? ", …" : ""))
                    }
                } else {
                    Text("ยังไม่มีไฟล์ model นี้ใน project").foregroundStyle(.secondary)
                }
            } header: {
                Text(entry.id).font(.headline)
            }
        }
        .navigationTitle("ข้างใน model")
        .task { entries = Self.load() }
    }

    /// แปลง input หรือ output แต่ละตัวเป็นข้อความสั้น ๆ เช่น "image: รูป 224 × 224"
    private func features(_ byName: [String: MLFeatureDescription]) -> [String] {
        byName.keys.sorted().map { name in
            let f = byName[name]!
            switch f.type {
            case .image:
                let c = f.imageConstraint
                return "\(name): รูป \(c?.pixelsWide ?? 0) × \(c?.pixelsHigh ?? 0)"
            case .string: return "\(name): ข้อความ"
            case .dictionary: return "\(name): ความมั่นใจของทุกป้าย"
            case .multiArray:
                let shape = f.multiArrayConstraint?.shape.map { "\($0)" }.joined(separator: " × ") ?? "?"
                return "\(name): ตัวเลข \(shape)"
            case .double: return "\(name): ตัวเลข"
            default: return "\(name)"
            }
        }
    }

    private static func load() -> [Entry] {
        let config = MLModelConfiguration()
        return [
            Entry(id: "EmotionClassifier", source: "Train เองใน Create ML", callWith: "NLModel (Natural Language)",
                  model: try? EmotionClassifier(configuration: config).model),
            Entry(id: "MobileNetV2", source: "Apple", callWith: "class ที่ Xcode สร้างให้",
                  model: try? MobileNetV2(configuration: config).model),
            Entry(id: "YOLOv3Tiny", source: "Apple", callWith: "Vision (CoreMLRequest)",
                  model: try? YOLOv3Tiny(configuration: config).model),
            Entry(id: "CommunityClassifier", source: "คนอื่น", callWith: "Vision (AnyImageClassifier)",
                  model: bundled("CommunityClassifier")),
        ]
    }

    /// model ที่โหลดจากชื่อไฟล์ ถ้ายังไม่มีไฟล์ได้ nil
    private static func bundled(_ name: String) -> MLModel? {
        Bundle.main.url(forResource: name, withExtension: "mlmodelc").flatMap { try? MLModel(contentsOf: $0) }
    }
}

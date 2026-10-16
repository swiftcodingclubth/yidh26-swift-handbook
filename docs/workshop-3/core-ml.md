# Core ML

**Core ML** คือ framework ที่ run machine learning model ใน app บนเครื่องทั้งหมด ไม่ต้องใช้ internet ใช้ได้ทั้ง model ที่ train เองใน [Create ML](create-ml.md) และ model สำเร็จรูปจาก Apple ใช้ได้ทั้ง Xcode 26 และ 27

| Model | มาจาก | ใช้ทำอะไร | หน้าใน starter |
|---|---|---|---|
| `EmotionClassifier` | Train เองใน [Create ML](create-ml.md) | อ่านข้อความแล้วบอกอารมณ์ | วันนี้รู้สึกอย่างไร |
| `MobileNetV2` | [Apple](#pretrained) | บอกว่าในรูปมีอะไร | ในรูปมีอะไร? |
| `YOLOv3Tiny` | [Apple](#yolo) | หาวัตถุทุกชิ้นในรูปพร้อมตำแหน่ง | หาวัตถุในรูป, หาวัตถุแบบ live |

## เพิ่ม model เข้า project

ลากไฟล์ `.mlmodel` เข้า Xcode project แล้วติ๊ก target ของ app Xcode จะสร้าง **Swift class ชื่อเดียวกับไฟล์** ให้อัตโนมัติ เช่น `EmotionClassifier.mlmodel` จะได้ class `EmotionClassifier`

คลิกไฟล์ model ใน Xcode เพื่อดู:

- **General**: ป้ายที่ model ตอบได้ เช่น ชื่ออารมณ์
- **Predictions**: ชื่อและขนาดของ input และ output ซึ่งต้องใช้ตอนเขียนโค้ด

## Model ที่ train เอง: Text Classifier { #text-classifier }

Text classifier จาก Create ML ใช้ผ่าน **`NLModel`** ของ framework Natural Language ส่งข้อความเข้าไป แล้วได้ความมั่นใจของทุกอารมณ์กลับมา ทายเร็วมาก (ไม่ถึง 1 ms ต่อประโยค) จึงทายใหม่ทุกครั้งที่ผู้ใช้พิมพ์ได้เลย

```swift
import CoreML
import NaturalLanguage

final class EmotionDetector {
    // Text classifier ใช้ผ่าน NLModel ของ Natural Language
    private let model = try! NLModel(mlModel: EmotionClassifier(configuration: MLModelConfiguration()).model)

    /// ความมั่นใจของทุกอารมณ์ เรียงจากมากไปน้อย เช่น [("joy", 0.82), ("love", 0.10), …]
    func scores(for text: String) -> [(label: String, confidence: Double)] {
        model.predictedLabelHypotheses(for: text, maximumCount: 6)
            .map { (label: $0.key, confidence: $0.value) }
            .sorted { $0.confidence > $1.confidence }
    }
}
```

ความมั่นใจของทุกอารมณ์รวมกันได้ 1 (100%) ตัวแรกคืออารมณ์ที่ model มั่นใจที่สุด

### ใช้ความมั่นใจตัดสิน { #confidence }

Model นี้ไม่มี `neutral` จะตอบอารมณ์ใดอารมณ์หนึ่งเสมอ แม้ข้อความจะไม่มีอารมณ์อะไร ถ้าอารมณ์ที่มั่นใจที่สุดยังมั่นใจไม่ถึงเกณฑ์ ให้แสดงว่า "ยังไม่แน่ใจ" แทนการเดา

```swift
let detector = EmotionDetector()
let scores = detector.scores(for: "today was a really good day")

if let top = scores.first, top.confidence >= 0.4 {
    print(top.label)       // มั่นใจพอ เช่น "joy"
} else {
    print("ยังไม่แน่ใจ")    // เช่น "i bought some milk" ซึ่งไม่มีอารมณ์
}
```

ปรับเกณฑ์ `0.4` ด้วยการลองพิมพ์จริง ยิ่งสูง ยิ่งขึ้น "ยังไม่แน่ใจ" บ่อย แต่ทายผิดน้อยลง

### Use case: วันนี้รู้สึกอย่างไร

หน้านี้ในแท็บ Core ML ของ starter project ใช้ `EmotionDetector` กับความมั่นใจเปลี่ยนหน้าจอทันทีที่พิมพ์

| ส่วน | ทำงานอย่างไร |
|---|---|
| Emoji และชื่ออารมณ์ | อารมณ์ที่มั่นใจที่สุด ถ้ามั่นใจไม่ถึง 40% ขึ้น 🤔 ยังไม่แน่ใจ |
| สีพื้นหลัง | สีของอารมณ์ ยิ่งมั่นใจยิ่งเข้ม |
| วงแหวน | เต็มตามความมั่นใจ |
| 3 อารมณ์อันดับแรก | ให้เห็นว่า model ลังเลระหว่างอารมณ์อะไร |

!!! tip "พิมพ์เป็นภาษาอังกฤษ"
    Model train จากข้อความภาษาอังกฤษ ช่องพิมพ์จึงตั้ง `.keyboardType(.asciiCapable)` ให้แป้นพิมพ์เป็นภาษาอังกฤษตั้งแต่แรก

## Performance และแบตเตอรี่

| เรื่อง | ทำอย่างไร |
|---|---|
| **โหลด model ครั้งเดียว** | สร้าง model ไว้ตัวเดียวแล้วใช้ซ้ำ การโหลดใหม่ทุกครั้งช้ามาก |
| **โหลดเมื่อจำเป็น** | สร้าง model ตอนเปิดหน้าที่ใช้ ไม่ใช่ตอนเปิด app หน้าแรกจะได้ขึ้นเร็ว |
| **ขนาด model** | Model เล็กโหลดเร็วและใช้ memory น้อย Text classifier จาก Create ML มีขนาดไม่ถึง 1 MB |
| **Quantization** | ลดความละเอียดของตัวเลขใน model (เช่น จาก 16 bit เหลือ 8 หรือ 4 bit) ทำให้ไฟล์เล็กและเร็วขึ้น แลกกับความแม่นที่ลดลงเล็กน้อย สำคัญกับ model ใหญ่อย่างใน [Core AI](core-ai.md) |

## ใช้ model สำเร็จรูปจาก Apple { #pretrained }

ไม่จำเป็นต้อง train เองเสมอไป Apple มี model ที่ train ไว้แล้วให้ดาวน์โหลดฟรีที่ [Core ML Models](https://developer.apple.com/machine-learning/models/) เช่น จำแนกรูปภาพ หาวัตถุในรูป และประมาณความลึก

ตัวอย่างนี้ใช้ **MobileNetV2** (ไฟล์ `MobileNetV2FP16.mlmodel` ขนาด 12 MB) ที่บอกได้ว่าในรูปมีอะไร จากกว่า 1,000 ประเภท เช่น สัตว์ อาหาร ยานพาหนะ ดาวน์โหลดแล้วเปลี่ยนชื่อไฟล์เป็น `MobileNetV2.mlmodel` ก่อนลากเข้า project จะได้ class ชื่อสั้นๆ ว่า `MobileNetV2`

```swift
import CoreML
import UIKit

final class ImageClassifier {
    private let model = try! MobileNetV2(configuration: MLModelConfiguration())

    func classify(_ image: UIImage) throws -> (label: String, confidence: Double) {
        guard let cgImage = image.cgImage else { return ("?", 0) }
        let input = try MobileNetV2Input(imageWith: cgImage)   // ย่อรูปเป็น 224 × 224 ให้เอง
        let output = try model.prediction(input: input)

        // ชื่อมีหลายแบบคั่นด้วยจุลภาค เช่น "golden retriever, ..." เอาแค่ชื่อแรก
        let name = output.classLabel.components(separatedBy: ",").first ?? output.classLabel
        return (name, output.classLabelProbs[output.classLabel] ?? 0)
    }
}
```

ชื่อที่ได้เป็นภาษาอังกฤษ เช่น `zebra`, `king penguin`, `pizza` ถ้าจะแสดงให้ผู้ใช้เห็นเป็นภาษาไทย ให้แปลงเอง

## หาวัตถุในรูปด้วย YOLOv3 { #yolo }

MobileNetV2 บอกได้แค่ว่ารูปทั้งรูปเป็นอะไร **YOLOv3** หาวัตถุ **ทุกชิ้น** ในรูป พร้อมตำแหน่งของแต่ละชิ้น จึงนับได้ว่ามีกี่ชิ้น และวาดกรอบรอบวัตถุได้ รู้จักวัตถุ 80 ประเภท เช่น คน สุนัข แมว จักรยาน รถ แก้ว ขวด เก้าอี้ โทรศัพท์

| | MobileNetV2 | YOLOv3 |
|---|---|---|
| ตอบว่า | รูปนี้คืออะไร (1 คำตอบ) | มีอะไรบ้าง อยู่ตรงไหน (หลายชิ้น) |
| ตัวอย่าง | "golden retriever" | "dog" 2 ตัว, "person" 1 คน พร้อมกรอบ |
| เหมาะกับ | รูปถ่ายใกล้ของชิ้นเดียว | รูปที่มีหลายอย่างในฉาก |

Apple มี YOLOv3 หลายขนาด ตัวอย่างนี้ใช้ **YOLOv3 Tiny** (`YOLOv3TinyFP16.mlmodel` 16 MB) ซึ่งเล็กและเร็ว แต่แม่นน้อยกว่าตัวเต็ม (`YOLOv3FP16.mlmodel` 118 MB) ดาวน์โหลดแล้วเปลี่ยนชื่อไฟล์เป็น `YOLOv3Tiny.mlmodel`

Model นี้ให้ผลเป็นตัวเลข 2 ชุดที่แปลงเองยาก จึงส่งผ่าน **Vision** ซึ่งย่อรูปให้ และแปลงผลเป็นชื่อวัตถุกับกรอบให้เลย

```swift
import CoreImage
import CoreML
import UIKit
import Vision

struct DetectedObject: Identifiable {
    let id = UUID()
    let label: String        // ชื่อวัตถุภาษาอังกฤษ เช่น "dog", "person"
    let confidence: Double   // 0–1
    let box: CGRect          // ตำแหน่ง 0–1 มุมบนซ้ายเป็น (0, 0) แบบ SwiftUI
}

final class ObjectDetector {
    // โหลด model ครั้งเดียวแล้วใช้ซ้ำ สำคัญมากเมื่อทายจากกล้องหลายครั้งต่อวินาที
    private let model = try! CoreMLModelContainer(model: YOLOv3Tiny(configuration: MLModelConfiguration()).model)

    /// หาวัตถุในรูปจาก Photos
    func detect(in image: UIImage) async throws -> [DetectedObject] {
        // วาดรูปใหม่ให้ตั้งตรงก่อน รูปจากกล้อง iPad มักเก็บแบบหมุนไว้
        let upright = UIGraphicsImageRenderer(size: image.size).image { _ in image.draw(at: .zero) }
        guard let cgImage = upright.cgImage else { return [] }
        return try await detect(CIImage(cgImage: cgImage))
    }

    /// หาวัตถุใน frame จากกล้องสด (frame จาก CameraView ตั้งตรงแล้ว)
    func detect(in frame: CVPixelBuffer) async throws -> [DetectedObject] {
        try await detect(CIImage(cvPixelBuffer: frame))
    }

    private func detect(_ image: CIImage) async throws -> [DetectedObject] {
        // ให้ Vision ช่วยย่อรูปเป็น 416 × 416 และแปลงผลจาก model เป็นชื่อวัตถุกับกรอบ
        var request = CoreMLRequest(model: model)
        request.cropAndScaleAction = .scaleToFill   // ใช้ทั้งรูป ไม่ตัดขอบ
        let results = try await request.perform(on: image)

        return results.compactMap { $0 as? RecognizedObjectObservation }.map { object in
            let rect = object.boundingBox.cgRect   // Vision: (0, 0) อยู่มุมล่างซ้าย
            return DetectedObject(
                label: object.labels.first?.identifier ?? "?",
                confidence: Double(object.labels.first?.confidence ?? 0),
                box: CGRect(x: rect.minX, y: 1 - rect.maxY, width: rect.width, height: rect.height))
        }
    }
}
```

`box` เป็นสัดส่วน 0–1 ของรูป ถ้าจะวาดกรอบบนจอ ให้คูณกับความกว้างและความสูงของรูปที่แสดงอยู่

!!! tip "ใช้รูปที่มีหลายอย่างในฉาก"
    YOLOv3 Tiny หาวัตถุในรูปถ่ายทั่วไปได้ดี เช่น คนกับสุนัข โต๊ะอาหาร ถนน แต่รูปถ่ายใกล้ที่ของชิ้นเดียวเต็มเฟรมมักหาไม่เจอ หรือทายผิด รูปแบบนั้นใช้ MobileNetV2 ดีกว่า

### หาวัตถุจากกล้องแบบ real time { #yolo-live }

ใช้ `ObjectDetector` ตัวเดิมกับภาพจากกล้องได้เลย หันกล้องไปที่ไหน app ก็ตีกรอบวัตถุให้ทันที ส่วนกล้องใช้ `CameraView` จาก [Workshop 5](../workshop-5/hand-pose.md) ซึ่งขอสิทธิ์กล้องให้ หมุนภาพให้ตั้งตรง และส่งภาพมาทีละ frame (`CVPixelBuffer`)

```swift
import AVFoundation
import SwiftUI

struct LiveDetectView: View {
    @State private var model = LiveDetector()

    var body: some View {
        CameraView(position: .back, onFrame: model.handle) {
            ObjectBoxes(objects: model.objects)   // วาดกรอบทับภาพจากกล้อง
        }
    }
}

@MainActor @Observable
final class LiveDetector {
    private(set) var objects: [DetectedObject] = []

    private let detector = ObjectDetector()
    private var isBusy = false

    func handle(_ frame: CVPixelBuffer) {
        guard !isBusy else { return }   // frame ก่อนหน้ายังทายไม่เสร็จ ข้ามไปก่อน app จะได้ไม่หน่วง
        isBusy = true
        Task {
            defer { isBusy = false }
            objects = (try? await detector.detect(in: frame)) ?? []
        }
    }
}
```

`ObjectBoxes` คือ view ที่วาดกรอบจาก `box` ของแต่ละชิ้น อยู่ใน starter project

| เรื่อง | ทำอย่างไร |
|---|---|
| **ข้าม frame** | กล้องส่งภาพมาเร็วกว่าที่ model ทายทัน ถ้า frame ก่อนหน้ายังไม่เสร็จให้ทิ้ง frame ใหม่ไป ไม่ต่อคิว |
| **โหลด model ครั้งเดียว** | `ObjectDetector` สร้าง model ไว้ตัวเดียวแล้วใช้ซ้ำ ถ้าโหลดใหม่ทุก frame จะช้ามาก |
| **ความเร็ว** | ตอนทดสอบบน Simulator ใช้ประมาณ 40 ms ต่อ frame (ประมาณ 25 frame ต่อวินาที) บน iPad ใช้ Neural Engine จะเร็วกว่านี้ |
| **ภาพเล็กลง** | `CameraView` ส่งภาพขนาด 640 × 480 วัตถุที่เล็กหรืออยู่ไกลอาจหาไม่เจอ ให้เข้าใกล้ขึ้น |
| **Permission** | ต้องมี `NSCameraUsageDescription` ใน Info.plist และต้อง run บน iPad จริง (Simulator ไม่มีกล้อง) |

!!! tip "ใช้ใน app ของทีม"
    โค้ดในหน้านี้อยู่ใน `MLParts/TextEmotion.swift`, `MLParts/ImageClassifier.swift`, `MLParts/ObjectDetector.swift` และ `MLParts/CameraView.swift` (พร้อมไฟล์ model) ของ [starter project](add-to-your-app.md#get-starter) copy ไปใช้ได้เลย ดูขั้นตอนที่[ใส่ใน app ของทีม](add-to-your-app.md)

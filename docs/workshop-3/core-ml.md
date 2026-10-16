# Core ML

**Core ML** คือ framework ที่ run machine learning model ใน app บนเครื่องทั้งหมด ไม่ต้องใช้ internet ใช้ได้ทั้ง model ที่ train เองใน [Create ML](create-ml.md) และ model สำเร็จรูปจาก Apple ใช้ได้ทั้ง Xcode 26 และ 27

| Model | มาจาก | ใช้ทำอะไร | หน้าใน starter |
|---|---|---|---|
| `EmotionClassifier` | Train เองใน [Create ML](create-ml.md) | อ่านข้อความแล้วบอกอารมณ์ | วันนี้รู้สึกอย่างไร |
| `MobileNetV2` | [Apple](#pretrained) | บอกว่าในรูปมีอะไร | ในรูปมีอะไร?, ของบนโต๊ะคืออะไร ([workshop](#workshop)) |
| `YOLOv3Tiny` | [Apple](#yolo) | หาวัตถุทุกชิ้นในรูปพร้อมตำแหน่ง | หาวัตถุในรูป, หาวัตถุแบบ live |
| Sentiment ในระบบ | [Apple (อยู่ใน iOS แล้ว)](#sentiment) | ข้อความนี้บวกหรือลบ | ข้อความบวกหรือลบ |
| `CommunityClassifier` | [คนอื่น](#community) | image classifier ตัวไหนก็ได้ | ใช้ model ของคนอื่น |

| แหล่ง model | Text | Image | Live (กล้อง) |
|---|---|---|---|
| Train เอง (Create ML) | EmotionClassifier | – | – |
| Apple | Sentiment ในระบบ | MobileNetV2, YOLOv3 | YOLOv3, MobileNetV2 ([workshop](#workshop)) |
| คนอื่น | – | CommunityClassifier | CommunityClassifier |

## เพิ่ม model เข้า project

ลากไฟล์ `.mlmodel` เข้า Xcode project แล้วติ๊ก target ของ app Xcode จะสร้าง **Swift class ชื่อเดียวกับไฟล์** ให้อัตโนมัติ เช่น `EmotionClassifier.mlmodel` จะได้ class `EmotionClassifier`

คลิกไฟล์ model ใน Xcode เพื่อดู:

- **General**: ป้ายที่ model ตอบได้ เช่น ชื่ออารมณ์
- **Predictions**: ชื่อและขนาดของ input และ output ซึ่งต้องใช้ตอนเขียนโค้ด

## อ่าน input และ output ก่อนเขียนโค้ด { #inspect }

Model ทุกตัวคือกล่องที่รับ input แบบหนึ่ง แล้วให้ output แบบหนึ่ง ก่อนเขียนโค้ดต้องรู้ 3 อย่าง

| ต้องรู้ | ดูที่ | ตัวอย่าง |
|---|---|---|
| **Input** เป็นอะไร ขนาดเท่าไหร่ | แท็บ Predictions › Input | MobileNetV2 รับรูป 224 × 224, YOLOv3 Tiny รับรูป 416 × 416, EmotionClassifier รับข้อความ |
| **Output** เป็นอะไร | แท็บ Predictions › Output | ป้ายที่มั่นใจที่สุด + ความมั่นใจของทุกป้าย หรือตัวเลขชุดใหญ่ที่ต้องแปลงเอง |
| **ป้าย** มีอะไรบ้าง | แท็บ General › Class labels | 6 อารมณ์, 1,000 ประเภทของ MobileNetV2, 80 ประเภทของ YOLOv3 |

หน้า **ข้างใน model** ในแท็บ Core ML ของ starter แสดงทั้ง 3 อย่างของทุก model ใน project โดยอ่านจาก `modelDescription` ซึ่งเป็นข้อมูลชุดเดียวกับแท็บ Predictions

```swift
let description = MobileNetV2().model.modelDescription
description.inputDescriptionsByName    // ["image": รูป 224 × 224]
description.outputDescriptionsByName   // ["classLabel": ข้อความ, "classLabelProbs": ความมั่นใจของทุกป้าย]
description.classLabels                // ป้ายทั้งหมด
```

## เรียกใช้ model ได้ 3 แบบ { #three-ways }

รู้ input และ output แล้ว เลือกวิธีเรียกตามชนิดข้อมูล

| แบบ | ใช้เมื่อ | ตัวอย่างในหน้านี้ |
|---|---|---|
| **Class ที่ Xcode สร้างให้** | input/output ง่าย และรู้ชื่อ model ตอนเขียนโค้ด | `MobileNetV2` ใน [ImageClassifier](#pretrained) |
| **Natural Language** (`NLModel`) | text classifier จาก Create ML | `EmotionClassifier` ใน [EmotionDetector](#text-classifier) |
| **Vision** (`CoreMLRequest`) | รูปและกล้อง Vision ย่อรูปให้ตรงขนาด และแปลงผลเป็นป้ายหรือกรอบให้ | `YOLOv3Tiny` ใน [ObjectDetector](#yolo), ทุก image classifier ใน [AnyImageClassifier](#community) |

ถ้าไม่แน่ใจ งานรูปภาพให้ใช้ Vision ไว้ก่อน เพราะไม่ต้องย่อรูปหรือแปลงผลเอง

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
        // วาดรูปใหม่ให้ตั้งตรงก่อน รูปจากกล้อง iPad มักเก็บแบบหมุนไว้ ถ้าใช้ image.cgImage ตรงๆ model จะเห็นรูปตะแคง
        let upright = UIGraphicsImageRenderer(size: image.size).image { _ in image.draw(at: .zero) }
        guard let cgImage = upright.cgImage else { return ("?", 0) }
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

## Model ในระบบ: ข้อความบวกหรือลบ { #sentiment }

บาง model Apple ใส่ไว้ใน iOS แล้ว ไม่ต้องดาวน์โหลดไฟล์หรือ train เช่น การวิเคราะห์ความรู้สึกของข้อความใน Natural Language ได้คะแนน -1 (ลบมาก) ถึง 1 (บวกมาก) ใช้กับข้อความภาษาอังกฤษ

```swift
import NaturalLanguage

func sentimentScore(of text: String) -> Double? {
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    tagger.string = text
    let (tag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
    return tag.flatMap { Double($0.rawValue) }
}
```

หน้า **ข้อความบวกหรือลบ** ใน starter ใช้ฟังก์ชันนี้ ลองพิมพ์ประโยคเดียวกันในหน้านี้และหน้า "วันนี้รู้สึกอย่างไร" แล้วเทียบกัน

| | Sentiment ในระบบ | EmotionClassifier ที่ train เอง |
|---|---|---|
| ตอบว่า | บวกหรือลบ เป็นตัวเลข | 1 ใน 6 อารมณ์ |
| ต้องเตรียม | ไม่ต้องเตรียมอะไร | ข้อมูล 18,000 ประโยค + train |
| ขนาดใน app | 0 (อยู่ใน iOS แล้ว) | ไม่ถึง 1 MB |

ถ้าแค่ต้องการรู้ว่าบวกหรือลบ ใช้ตัวในระบบได้เลย ถ้าต้องการแยกละเอียดกว่านั้น ค่อย train เอง

## ใช้ model ของคนอื่น { #community }

นอกจากของ Apple ยังมี Core ML model ที่คนอื่น train และแปลงไว้แล้ว เช่น บน [Hugging Face](https://huggingface.co/models?library=coreml) (ค้นด้วย library `coreml`) หรือแปลง model จาก PyTorch เองด้วย [Core ML Tools](https://apple.github.io/coremltools/docs-guides/) ซึ่งต้องใช้ Python

**เช็กก่อนเอามาใช้**

| เช็ก | ทำไม |
|---|---|
| **License** | บาง model ใช้ในงานเชิงพาณิชย์ไม่ได้ หรือบังคับให้เปิดโค้ดทั้ง app |
| **ขนาดไฟล์** | Model จาก community หลายตัวใหญ่หลายร้อย MB เช่น ViT ที่แปลงเป็น Core ML มีขนาด 346 MB ทำให้ app ใหญ่และโหลดช้า เลือกตัวที่เล็กกว่า 50 MB ถ้าทำได้ |
| **Input และ Output** | ดูแท็บ Predictions ตาม[หัวข้อนี้](#inspect) ว่าเป็น image classifier ที่ Vision ใช้ได้ไหม |
| **iOS ขั้นต่ำ** | ไฟล์ `.mlpackage` บางตัวต้องใช้ iOS รุ่นใหม่ ดูในแท็บ General |

ถ้าเป็น image classifier ใช้ `AnyImageClassifier` ได้เลย ไม่ต้องรู้ชื่อ class ล่วงหน้า เพราะโหลด model จากชื่อไฟล์ และให้ Vision ย่อรูปให้ตรงกับที่ model ต้องการ ใช้ได้กับ model ทุกตัว ทั้งของ Apple ของคนอื่น และที่ train เอง

```swift
import CoreML
import Vision

final class AnyImageClassifier {
    private let model: CoreMLModelContainer

    /// ชื่อไฟล์ model ไม่ต้องมีนามสกุล ถ้าไม่มีไฟล์นี้ใน project ได้ nil
    init?(named name: String) {
        // Xcode compile ไฟล์ .mlmodel และ .mlpackage เป็น .mlmodelc ตอน build
        guard let url = Bundle.main.url(forResource: name, withExtension: "mlmodelc"),
              let mlModel = try? MLModel(contentsOf: url),
              let container = try? CoreMLModelContainer(model: mlModel) else { return nil }
        model = container
    }

    func classify(_ frame: CVPixelBuffer) async throws -> [ImageGuess] {
        var request = CoreMLRequest(model: model)
        request.cropAndScaleAction = .centerCrop
        let results = try await request.perform(on: CIImage(cvPixelBuffer: frame))
        return results.compactMap { $0 as? ClassificationObservation }
            .map { ImageGuess(label: $0.identifier, confidence: Double($0.confidence)) }
            .sorted { $0.confidence > $1.confidence }
    }
}
```

ไฟล์เต็มใน starter มี `classify` สำหรับรูปจาก Photos ด้วย หน้า **ใช้ model ของคนอื่น** ใช้ไฟล์ชื่อ `CommunityClassifier` ลากไฟล์ `.mlmodel` หรือ `.mlpackage` ที่ดาวน์โหลดมา เปลี่ยนชื่อเป็น `CommunityClassifier` แล้ว run ใหม่ ทดสอบได้ทั้งรูปจาก Photos และกล้องสด

## Workshop: ของบนโต๊ะคืออะไร { #workshop }

ใช้ MobileNetV2 ของ Apple ที่มีอยู่ใน starter แล้ว ไม่ต้อง train เอง ส่งภาพจากกล้องสดผ่าน `AnyImageClassifier` แล้วเปลี่ยนคำตอบภาษาอังกฤษของ model เป็นสิ่งที่ผู้ใช้อ่านเข้าใจ หันกล้องไปที่ของบนโต๊ะ app บอกเป็นภาษาไทยพร้อมไอคอน

เปิดหน้า **ของบนโต๊ะคืออะไร** ในแท็บ Core ML กล้องและการทายทำไว้ให้แล้ว เขียนเฉพาะส่วนที่มี `TODO` ใน `Tabs/CoreML/DeskClassifierView.swift`

1. **TODO 1: ดูว่า model ตอบอะไร** หันกล้องไปที่ของบนโต๊ะทีละชิ้น เช่น ปากกา แก้ว ขวดน้ำ โทรศัพท์ คีย์บอร์ด เมาส์ แล้วจดชื่อที่ model ตอบจากรายการด้านล่างจอ เช่น `coffee mug`, `ballpoint`
2. **TODO 2: ใช้ความมั่นใจ** ถ้าคำตอบแรกมั่นใจต่ำกว่าเกณฑ์ ให้แสดงว่า "ไม่แน่ใจ" แทนการเดา MobileNetV2 รู้จัก 1,000 ประเภท ความมั่นใจจึงมักไม่สูง ลองเริ่มที่ 0.3 แล้วปรับ
3. **TODO 3: แปลงชื่อ** เปลี่ยนชื่อจาก TODO 1 เป็น SF Symbol และชื่อภาษาไทย เช่น `coffee mug` → `cup.and.saucer.fill` แก้วกาแฟ ของที่ไม่อยู่ในรายการให้แสดงว่าไม่ใช่ของบนโต๊ะที่รู้จัก

!!! tip "ทำไมต้องจดชื่อจาก model ก่อน"
    Model ไม่ได้ใช้ชื่อแบบที่เราเรียก เช่น ปากกาลูกลื่นชื่อ `ballpoint` และโทรศัพท์ชื่อ `cellular telephone` ถ้าเดาชื่อเอง จะไม่ตรงกับที่ model ตอบ และแปลงไม่ได้

**ต่อยอด** สำหรับคนที่ทำเสร็จก่อน

- นับว่าเจอของบนโต๊ะครบกี่อย่างแล้ว ทำเป็นเกมหาของ
- เปลี่ยนสีพื้นหลังหรือเล่นเสียงเมื่อเจอของที่กำหนด
- เปลี่ยนไปใช้ model ของคนอื่นใน[หัวข้อก่อนหน้า](#community) ด้วยการเปลี่ยนชื่อใน `AnyImageClassifier(named:)` แล้วเทียบผล

??? success "เฉลย"
    ไฟล์เฉลยทั้งไฟล์อยู่ที่ `starter/workshop-3/Solutions/DeskClassifierView.swift` ซึ่งอยู่นอก target จึงไม่ถูก compile ชื่อใน `names` ต้องตรงกับที่ model ตอบจริง

    ```swift
    private let minimumConfidence = 0.3

    private let names: [String: (icon: String, name: String)] = [
        "ballpoint": ("pencil", "ปากกา"),
        "coffee mug": ("cup.and.saucer.fill", "แก้วกาแฟ"),
        "water bottle": ("waterbottle.fill", "ขวดน้ำ"),
        "cellular telephone": ("iphone", "โทรศัพท์"),
        "computer keyboard": ("keyboard", "คีย์บอร์ด"),
        "mouse": ("computermouse.fill", "เมาส์"),
        "laptop": ("laptopcomputer", "แล็ปท็อป"),
        "notebook": ("laptopcomputer", "แล็ปท็อป"),
    ]

    private func describe(_ guesses: [ImageGuess]) -> (icon: String, name: String) {
        guard let top = guesses.first?.shortened else { return ("camera", "หันกล้องไปที่ของบนโต๊ะ") }
        guard top.confidence >= minimumConfidence else { return ("questionmark.circle", "ไม่แน่ใจ") }
        return names[top.label] ?? ("xmark.circle", "ไม่ใช่ของบนโต๊ะที่รู้จัก")
    }
    ```

!!! tip "ใช้ใน app ของทีม"
    โค้ดในหน้านี้อยู่ใน `MLParts/TextEmotion.swift`, `MLParts/ImageClassifier.swift`, `MLParts/ObjectDetector.swift`, `MLParts/AnyImageClassifier.swift`, `MLParts/Sentiment.swift` และ `MLParts/CameraView.swift` (พร้อมไฟล์ model) ของ [starter project](add-to-your-app.md#get-starter) copy ไปใช้ได้เลย ดูขั้นตอนที่[ใส่ใน app ของทีม](add-to-your-app.md)

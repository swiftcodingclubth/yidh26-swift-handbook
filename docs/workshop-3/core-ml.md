# Core ML

**Core ML** คือ framework ที่ run machine learning model ใน app บนเครื่องทั้งหมด ไม่ต้องใช้ internet model ที่ได้จาก [Create ML](create-ml.md) ใช้กับ Core ML ได้ทันที ใช้ได้ทั้ง Xcode 26 และ 27

## เพิ่ม model เข้า project

ลากไฟล์ `.mlmodel` เข้า Xcode project แล้วติ๊ก target ของ app Xcode จะสร้าง **Swift class ชื่อเดียวกับไฟล์** ให้อัตโนมัติ เช่น `GestureClassifier.mlmodel` จะได้ class `GestureClassifier`

คลิกไฟล์ model ใน Xcode เพื่อดู:

- **General**: ป้ายที่ model ตอบได้ (ชื่อท่า)
- **Predictions**: ชื่อและขนาดของ input และ output ซึ่งต้องใช้ตอนเขียนโค้ด

## Input และ output ของ Activity Classifier

| | ชื่อ | คืออะไร |
|---|---|---|
| Input | ชื่อตาม column ที่เลือกตอน train เช่น `accelX`, `rotationY` | ค่า sensor ของแต่ละแกน เป็น array ยาวเท่า prediction window (100 ค่า) |
| Input | `stateIn` | "ความจำ" จากการทายครั้งก่อน ครั้งแรกให้เป็นค่าว่าง |
| Output | `label` | ชื่อท่าที่มั่นใจที่สุด |
| Output | `labelProbability` | ความมั่นใจของทุกท่า เป็น dictionary ค่า 0–1 |
| Output | `stateOut` | ส่งกลับไปเป็น `stateIn` ในการทายครั้งถัดไป |

`stateIn`/`stateOut` ทำให้ model จำสิ่งที่เห็นใน window ก่อนหน้าได้ ท่าที่คร่อมสอง window จึงทายได้ดีขึ้น

## ส่งข้อมูลให้ model

ใช้ window จาก [Core Motion](core-motion.md#window) เมื่อครบ 100 sample ก็แปลงเป็น `MLMultiArray` แล้วทาย ชื่อ parameter ของ `GestureClassifierInput` ต้องตรงกับชื่อในแท็บ Predictions ของ model ตัวเอง ตัวอย่างนี้สมมติว่า train ด้วย 6 column

```swift
import CoreML
import CoreMotion

final class GesturePredictor {
    private let model = try! GestureClassifier(configuration: MLModelConfiguration())
    private var state = try! MLMultiArray(shape: [400], dataType: .double)  // ขนาดดูในแท็บ Predictions

    func predict(_ window: [CMDeviceMotion]) throws -> (label: String, confidence: Double) {
        func column(_ value: (CMDeviceMotion) -> Double) throws -> MLMultiArray {
            let array = try MLMultiArray(shape: [NSNumber(value: window.count)], dataType: .double)
            for (i, sample) in window.enumerated() { array[i] = NSNumber(value: value(sample)) }
            return array
        }

        let input = GestureClassifierInput(
            accelX: try column { $0.userAcceleration.x },
            accelY: try column { $0.userAcceleration.y },
            accelZ: try column { $0.userAcceleration.z },
            rotationX: try column { $0.rotationRate.x },
            rotationY: try column { $0.rotationRate.y },
            rotationZ: try column { $0.rotationRate.z },
            stateIn: state)

        let output = try model.prediction(input: input)
        state = output.stateOut   // เก็บไว้ใช้ครั้งถัดไป
        return (output.label, output.labelProbability[output.label] ?? 0)
    }
}
```

### ทายท่าด้วย model { #predict }

ให้ผู้ใช้กด **เริ่ม** ทำท่า แล้วกด **หยุด** app จึงค่อยทายว่าเป็นท่าอะไร ระหว่างอัดยังไม่ต้องทาย แค่เก็บค่าไว้

Model ต้องการข้อมูลก้อนละ 100 ค่า (2 วินาที) แต่แต่ละครั้งผู้ใช้อาจอัดยาวไม่เท่ากัน ตอนกดหยุดจึงหั่นข้อมูลเป็นก้อนด้วย `MotionWindow` ทายทีละก้อน แล้วเลือกท่าที่ความมั่นใจรวมสูงสุด

```swift
struct PredictView: View {
    @State private var isRecording = false
    @State private var recorded: [CMDeviceMotion] = []
    @State private var label = "–"

    var body: some View {
        VStack {
            Text(isRecording ? "กำลังอัด…" : label)
            Button(isRecording ? "หยุดและทาย" : "เริ่มทำท่า") {
                isRecording ? stop() : start()
            }
        }
        .onDisappear { stopMotionUpdates() }
    }

    // 1. กดเริ่ม: เก็บค่าไว้ก่อน ยังไม่ทาย
    private func start() {
        recorded = []
        isRecording = true
        startMotionUpdates { sample in
            recorded.append(sample)
        }
    }

    // 2. กดหยุด: หยุด sensor แล้วค่อยทายจากข้อมูลทั้งหมดที่อัดไว้
    private func stop() {
        stopMotionUpdates()
        isRecording = false
        guard recorded.count >= 100 else { label = "สั้นไป"; return }  // อย่างน้อย 2 วินาที

        var window = MotionWindow()
        let predictor = GesturePredictor()   // สร้างใหม่ทุกครั้ง ความจำ (stateIn) จะได้เริ่มจากว่าง
        var scores: [String: Double] = [:]   // ชื่อท่า → ความมั่นใจรวมทุกก้อน
        for sample in recorded {
            if let samples = window.add(sample),           // หั่นเป็นก้อนละ 100 ค่า
               let result = try? predictor.predict(samples) {
                scores[result.label, default: 0] += result.confidence
            }
        }
        label = scores.max { $0.value < $1.value }?.key ?? "–"   // ท่าที่มั่นใจรวมสูงสุด
    }
}
```

ไฟล์ที่ใช้โค้ดนี้ต้อง `import CoreMotion` ด้วย เพราะใช้ type `CMDeviceMotion`

!!! warning "ค่าที่ส่งต้องเหมือนตอน train"
    ใช้ค่า sensor ชนิดเดียวกัน (เช่น `userAcceleration` ไม่ใช่ accelerometer ดิบ), หน่วยเดียวกัน, sampling rate เดียวกัน และลำดับแกนเดียวกับที่ Motion Recorder บันทึก ถ้าไม่ตรง model จะทายผิดโดยไม่มี error

## ไปต่อ: ทายต่อเนื่องแบบ real time { #smoothing }

ถ้าอยากให้ app ทายเองตลอดโดยไม่ต้องกดปุ่ม ให้ทายทันทีที่ `window.add` คืนก้อนข้อมูลมา จะได้ผลใหม่ทุก 1 วินาที

```swift
startMotionUpdates { sample in
    if let samples = window.add(sample),
       let result = try? predictor.predict(samples) {
        label = result.label
    }
}
```

แบบนี้บางครั้ง model ทายผิดไปหนึ่งครั้งแล้วกลับมาถูก ถ้าแสดงผลทุกครั้งตรงๆ หน้าจอจะกระพริบสลับไปมา ให้ดูผลหลายครั้งล่าสุด แล้วแสดงท่าที่ทายได้บ่อยที่สุด และเฉพาะเมื่อมั่นใจพอ

```swift
struct Smoother {
    private var recent: [String] = []

    mutating func add(_ label: String, confidence: Double) -> String? {
        guard confidence > 0.6 else { return nil }   // ไม่มั่นใจ ไม่นับ
        recent.append(label)
        if recent.count > 5 { recent.removeFirst() } // เก็บ 5 ครั้งล่าสุด

        let counts = Dictionary(recent.map { ($0, 1) }, uniquingKeysWith: +)
        guard let (best, count) = counts.max(by: { $0.value < $1.value }),
              count >= 3 else { return nil }         // ต้องชนะอย่างน้อย 3 ใน 5
        return best
    }
}
```

## Performance และแบตเตอรี่

| เรื่อง | ทำอย่างไร |
|---|---|
| **Sampling rate** | ใช้ rate ต่ำที่สุดที่ยังจดจำท่าได้ 50 Hz พอสำหรับท่าทางส่วนใหญ่ |
| **เรียก model เท่าที่จำเป็น** | ทายเมื่อ window ครบ ไม่ใช่ทุก sample และหยุด sensor เมื่อออกจากหน้าจอ |
| **โหลด model ครั้งเดียว** | สร้าง model ไว้ตัวเดียวแล้วใช้ซ้ำ การโหลดใหม่ทุกครั้งช้ามาก |
| **ขนาด model** | Model เล็กโหลดเร็วและใช้ memory น้อย Activity และ Sound Classifier จาก Create ML มักมีขนาดเล็กอยู่แล้ว |
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

!!! tip "ใช้ใน app ของทีม"
    โค้ดในหน้านี้อยู่ใน `SensorParts/Gesture.swift` และ `SensorParts/ImageClassifier.swift` (พร้อมไฟล์ model) ของ [starter project](add-to-your-app.md#get-starter) copy ไปใช้ได้เลย ดูขั้นตอนที่[ใส่ใน app ของทีม](add-to-your-app.md)

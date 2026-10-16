# Sound recognition

**Sound Analysis** คือ framework ที่ฟังเสียงจากไมโครโฟนแล้วบอกว่าเป็นเสียงอะไร มี **classifier ในตัวที่รู้จักเสียงกว่า 300 แบบ** เช่น เสียงกริ่ง สุนัขเห่า เด็กร้อง ปรบมือ สัญญาณเตือนไฟไหม้ และเครื่องดนตรี ใช้ได้ทันทีโดยไม่ต้อง train และ run บนเครื่องทั้งหมด เสียงไม่ถูกส่งออกไปไหน ใช้ได้ทั้ง Xcode 26 และ 27

ถ้าต้องการจดจำเสียงเฉพาะที่ classifier ในตัวไม่รู้จัก เช่น เสียงไอแบบต่าง ๆ ให้ train model เองด้วย template **Sound Classification** ใน Create ML (ไม่อยู่ใน workshop นี้) แล้วใช้กับโค้ดชุดเดียวกันในหน้านี้

## ทำงานอย่างไร

1. **`AVAudioEngine`** รับเสียงจากไมโครโฟนเป็นชิ้นเล็ก ๆ ต่อเนื่อง
2. **`SNAudioStreamAnalyzer`** รับเสียงแต่ละชิ้นไปวิเคราะห์
3. **`SNClassifySoundRequest`** บอกว่าจะใช้ classifier ตัวไหน (ในตัวหรือที่ train เอง)
4. **Observer** ของเราได้ผลลัพธ์เป็นรายการเสียงพร้อมความมั่นใจ (0–1) ทุกช่วงเวลา

## Permission

ใส่ข้อความอธิบายใน Info.plist ไม่อย่างนั้น app จะ crash ตอนเปิดไมโครโฟน

```text
NSMicrophoneUsageDescription
    "ฟังเสียงรอบตัวเพื่อแจ้งเตือนเมื่อได้ยินเสียงสำคัญ"
```

แล้วขออนุญาตก่อนเริ่มฟัง:

```swift
import AVFoundation

let granted = await AVAudioApplication.requestRecordPermission()
```

## ฟังและจดจำเสียง

Class นี้รวมทุกขั้นตอนไว้ เรียก `start()` เพื่อเริ่มฟัง และได้ชื่อเสียงที่มั่นใจที่สุดกลับมาทาง `onResult`

```swift
import AVFoundation
import SoundAnalysis

final class SoundListener: NSObject, SNResultsObserving {
    private let engine = AVAudioEngine()
    private var analyzer: SNAudioStreamAnalyzer?
    private let queue = DispatchQueue(label: "SoundAnalysis")
    var onResult: (String, Double) -> Void = { _, _ in }

    func start() throws {
        // 1. ตั้งค่า audio session ให้รับเสียงจากไมโครโฟน
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement)
        try session.setActive(true)

        // 2. สร้าง analyzer และ request ของ classifier ในตัว
        let format = engine.inputNode.outputFormat(forBus: 0)
        let analyzer = SNAudioStreamAnalyzer(format: format)
        let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
        try analyzer.add(request, withObserver: self)
        self.analyzer = analyzer

        // 3. ส่งเสียงจากไมโครโฟนให้ analyzer ทีละชิ้น
        engine.inputNode.installTap(onBus: 0, bufferSize: 8192, format: format) { [weak self] buffer, time in
            self?.queue.async {
                self?.analyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
        try engine.start()
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        analyzer?.removeAllRequests()
    }

    // 4. ได้ผลลัพธ์ทุกช่วงเวลา
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let top = result.classifications.first else { return }
        DispatchQueue.main.async {
            self.onResult(top.identifier, top.confidence)
        }
    }
}
```

!!! note "ชื่อเสียงเป็นภาษาอังกฤษแบบ identifier"
    ผลลัพธ์เป็นชื่ออย่าง `"dog_bark"`, `"door_bell"`, `"baby_crying"` ไว้ใช้ในโค้ด ถ้าจะแสดงให้ผู้ใช้เห็น ให้แปลงเป็นข้อความภาษาไทยเอง

## ดูรายชื่อเสียงที่รู้จัก

อยากรู้ว่า classifier ในตัวรู้จักเสียงอะไรบ้าง ให้ print รายชื่อออกมา แล้วเลือกเฉพาะเสียงที่ app ต้องใช้

```swift
let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
print(request.knownClassifications)   // ["acoustic_guitar", "airplane", ...]
```

## ปรับให้แม่นขึ้น

**ตั้งเกณฑ์ความมั่นใจ** classifier จะตอบเสมอแม้ในห้องเงียบ ถ้าไม่กรอง app จะแจ้งเตือนผิดบ่อย ให้รับเฉพาะผลที่มั่นใจพอ และเฉพาะเสียงที่สนใจ

```swift
let important: Set = ["smoke_detector", "door_bell", "baby_crying"]

listener.onResult = { sound, confidence in
    guard important.contains(sound), confidence > 0.7 else { return }
    // แจ้งเตือนผู้ใช้
}
```

**ปรับความยาวช่วงเสียง** classifier ฟังเสียงเป็นช่วง ๆ ช่วงยาวแม่นกว่าแต่ตอบช้ากว่า และ `overlapFactor` คือสัดส่วนที่ช่วงติดกันซ้อนทับกัน ซ้อนมากได้ผลถี่ขึ้นแต่ใช้ CPU มากขึ้น

```swift
request.windowDuration = CMTime(seconds: 1.5, preferredTimescale: 48_000)  // ฟังทีละ 1.5 วินาที
request.overlapFactor = 0.5                                                // ซ้อนกัน 50%
```

## ใช้ model เสียงที่ train เอง

เมื่อ train sound classifier ด้วย template Sound Classification ใน Create ML แล้วลากไฟล์ model เข้า Xcode ให้เปลี่ยนแค่บรรทัดที่สร้าง request ส่วนอื่นเหมือนเดิมทั้งหมด

```swift
let request = try SNClassifySoundRequest(mlModel: CoughClassifier().model)
```

`CoughClassifier` คือ class ที่ Xcode สร้างจากชื่อไฟล์ model ของเรา

## Privacy และแบตเตอรี่

- การวิเคราะห์เสียงทำบนเครื่องทั้งหมด ไม่ต้องใช้ internet
- เมื่อไมโครโฟนเปิดอยู่ iPadOS จะแสดงจุดสีส้มที่มุมจอ ผู้ใช้รู้เสมอว่า app กำลังฟัง
- หยุดฟัง (`stop()`) เมื่อออกจากหน้าจอ ไมโครโฟนและการวิเคราะห์ที่เปิดค้างกินแบตเตอรี่

!!! tip "ใช้ใน app ของทีม"
    โค้ดในหน้านี้อยู่ใน `SensorParts/Sound.swift` ของ [starter project](add-to-your-app.md#get-starter) copy ไปใช้ได้เลย ดูขั้นตอนที่[ใส่ใน app ของทีม](add-to-your-app.md)

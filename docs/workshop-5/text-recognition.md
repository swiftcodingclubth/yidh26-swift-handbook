# อ่านข้อความจากรูป

**`RecognizeTextRequest`** คือ request ของ Vision ที่หาตัวหนังสือในรูปแล้วแปลงเป็น `String` ทีละบรรทัด ต่างจาก [VisionKit](visionkit.md) ตรงที่ใช้กับรูปที่มีอยู่แล้ว ไม่ต้องมีคนถือกล้อง ใช้ได้ทั้ง Xcode 26 และ 27

ใช้ทำอะไรได้: ค้นหาคำในรูปกระดานที่ถ่ายไว้, อ่านข้อความจากใบงานที่ scan, ดึงตัวเลขจากใบเสร็จ, ทำ flashcard จากหน้าหนังสือ

ข้อจำกัด:

- **ลองบน Simulator ได้** เพราะไม่ใช้กล้อง ลากรูปไปวางบนหน้าจอ Simulator เพื่อเพิ่มเข้า Photos ก่อน ส่วนหัวข้อ 3 ที่อ่านต่อจากเอกสารที่ scan ต้องใช้ iPad จริง
- **ได้ข้อความทีละบรรทัด ไม่รู้โครงสร้าง** แยกไม่ได้ว่าส่วนไหนเป็นตาราง หัวข้อ หรือ list ถ้าต้องการ ดู [ไปต่อ](#next)
- **ลายมือและตัวหนังสือเอียงมากอ่านได้ไม่ดี** รูปเบลอ แสงน้อย หรือตัวหนังสือเล็กมากก็เช่นกัน
- **รูปต้องตั้งตรง** ถ้ารูปหมุนอยู่ ต้องบอก orientation ให้ Vision
- **ภาษาที่อ่านได้ขึ้นกับเครื่อง** iPad ของงานอ่านภาษาไทยได้ แต่ถ้าเอา app ไปลงเครื่องอื่น ให้เช็กตาม[ปัญหาที่เจอบ่อย](#troubleshooting)

## 1. เลือกรูปจาก Photos { #pick-photo }

`PhotosPicker` ไม่ต้องขอ permission เพราะผู้ใช้เลือกรูปเอง app เห็นแค่รูปที่ถูกเลือก

```swift
import SwiftUI
import PhotosUI

struct ReadPhotoScreen: View {
    @State private var item: PhotosPickerItem?
    @State private var lines: [String] = []

    var body: some View {
        VStack {
            PhotosPicker("เลือกรูป", selection: $item, matching: .images)
            List(lines, id: \.self) { Text($0) }
        }
        .onChange(of: item) {
            Task {
                guard let data = try? await item?.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                lines = (try? await readText(from: image)) ?? []
            }
        }
    }
}
```

## 2. อ่านข้อความ { #read }

นี่คือ pattern 3 ขั้นของ Vision: สร้าง request → `perform(on:)` → อ่าน observation

```swift
import UIKit
import Vision

func readText(from image: UIImage) async throws -> [String] {
    guard let cgImage = image.cgImage else { return [] }

    // 1. สร้าง request
    var request = RecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.recognitionLanguages = [Locale.Language(identifier: "th-TH"),
                                    Locale.Language(identifier: "en-US")]

    // 2. perform กับรูป: บอกทิศของรูปด้วย ไม่อย่างนั้นรูปจากกล้องที่หมุนอยู่จะอ่านไม่ออก
    let observations = try await request.perform(
        on: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))

    // 3. อ่านผล: แต่ละ observation คือ 1 บรรทัด
    return observations.map(\.transcript)
}
```

`.accurate` แม่นกว่าแต่ช้ากว่า `.fast` เหมาะกับรูปนิ่ง ถ้ารูปมาจากกล้องทุก frame ให้ใช้ `.fast` แต่ละบรรทัดมี `confidence` (0–1) ด้วย ใช้กรองบรรทัดที่ไม่แน่ใจออกได้

`CGImagePropertyOrientation(_:)` ที่แปลงทิศจาก `UIImage` และการเลือกเฉพาะภาษาที่เครื่องรองรับ อยู่ใน `VisionParts/TextReader.swift` ของ starter project ใช้ไฟล์นั้นแทนการพิมพ์เองได้เลย

## 3. อ่านต่อจากเอกสารที่ scan { #from-scan }

หน้าที่ได้จาก [Document Camera](visionkit.md#document-camera) เป็น `UIImage` อยู่แล้ว จึงส่งต่อได้เลย

```swift
DocumentScannerView { pages in
    showScanner = false
    Task {
        var all: [String] = []
        for page in pages {
            all += (try? await readText(from: page)) ?? []
        }
        lines = all
    }
}
```

## ปัญหาที่เจอบ่อย { #troubleshooting }

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| รูปจากกล้องอ่านไม่ได้หรือได้ตัวอักษรแปลกๆ | รูปหมุนอยู่ Vision เห็นตัวหนังสือตะแคง | ส่ง `orientation:` ให้ `perform(on:orientation:)` ตามทิศของรูป ดูหัวข้อ 2 |
| ภาษาไทยออกมาเป็นอังกฤษมั่วๆ | ไม่ได้ใส่ `th-TH` หรือ run บนเครื่องอื่นที่ไม่รองรับ | พิมพ์ `request.supportedRecognitionLanguages` หรือเปิดแท็บ Languages ใน starter ดูว่ามีไทยไหม |
| Agent หรือ Google ให้โค้ดที่มี `VNRecognizeTextRequest` | เป็น API แบบเก่า | ใช้ได้ แต่ยาวกว่า บอก agent ว่า "ใช้ Vision Swift API แบบใหม่ `RecognizeTextRequest`" |
| Error ว่าภาษาไม่รองรับ | ใส่ภาษาที่เครื่องนี้ไม่มีใน `recognitionLanguages` | ใช้ `readText(from:)` จาก `TextReader.swift` ซึ่งเลือกเฉพาะภาษาที่รองรับให้ |
| ช้ามากกับรูปใหญ่ | `.accurate` กับรูปหลายล้าน pixel | ย่อรูปก่อน หรือใช้ `.fast` |

## ใช้ร่วมกับ

- [VisionKit](visionkit.md): ได้รูปเอกสารที่ตัดขอบแล้ว อ่านแม่นกว่ารูปถ่ายธรรมดา
- [Foundation Models](../workshop-2/foundation-models.md): ส่งข้อความที่อ่านได้ให้ model ตอบเป็น `@Generable` struct เช่น รายการสินค้าและราคาจากใบเสร็จ

## ไปต่อ { #next }

- **อ่านเอกสารแบบรู้โครงสร้าง** (iOS 26): ถ้าต้องการรู้ว่าส่วนไหนเป็นย่อหน้า ตาราง หรือ list ไม่ใช่แค่ข้อความทีละบรรทัด ใช้ `RecognizeDocumentsRequest` ได้ผลเป็น `DocumentObservation` ที่มีโครงสร้างของเอกสาร เหมาะกับใบเสร็จ ตาราง และฟอร์ม ดู [WWDC25: Read documents using the Vision framework](https://developer.apple.com/videos/play/wwdc2025/272/)

!!! mchip "{{ mac.apple }} · Xcode 27: ให้ AI ดูรูปเอง"
    ใน iOS 27 ส่งรูปให้ Foundation Models ได้ตรงๆ ด้วย `Attachment` และถ้า import ทั้ง `FoundationModels` และ `Vision` จะได้ `OCRTool` กับ `BarcodeReaderTool` ที่ model เรียกใช้อ่านข้อความและ barcode ในรูปเองได้ ไม่ต้องเรียก `readText(from:)` ก่อน

    ```swift
    import FoundationModels
    import Vision

    let model = SystemLanguageModel.default
    guard model.capabilities.contains(.vision) else { return }   // เครื่องนี้รับรูปได้ไหม

    let session = LanguageModelSession(model: model, tools: [OCRTool(), BarcodeReaderTool()])
    let response = try await session.respond {
        "สรุปใบเสร็จนี้: ร้านอะไร ซื้ออะไรบ้าง รวมเท่าไร (รูปที่แนบมีชื่อว่า receipt)"
        Attachment(cgImage).label("receipt")
    }
    ```

    ต้องตั้ง `.label(...)` ให้รูปและบอกชื่อนั้นใน prompt ไม่อย่างนั้น model จะเดาชื่อรูปเอง แล้ว `OCRTool` หารูปไม่เจอ (error `No image in transcript with label …`)

    เป็น API ของ iOS 27 ครอบโค้ดด้วย `#if compiler(>=6.4)` และใส่ `@available(iOS 27, *)` ให้ฟังก์ชันที่ใช้ ตาม[วิธีในหน้าเริ่มต้นใช้งาน](../getting-started.md#project-xcode-26-27) เพื่อให้เพื่อนที่ใช้ Xcode 26 ยัง build project ได้ ดูพื้นฐาน `LanguageModelSession` ใน [Workshop 2](../workshop-2/foundation-models.md)

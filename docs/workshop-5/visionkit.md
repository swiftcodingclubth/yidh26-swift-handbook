# VisionKit

**VisionKit** คือชุดหน้าจอสำเร็จรูปที่ Apple รวมกล้องกับ Vision ไว้ให้แล้ว แบบเดียวกับ Live Text ในแอป Camera และการ scan เอกสารในแอป Notes เราแค่เปิดหน้าจอแล้วรอรับผล ไม่ต้องจัดการกล้องหรือเรียก Vision เอง ใช้ได้ทั้ง Xcode 26 และ 27

ใช้ทำอะไรได้: อ่านเมนูหรือป้าย, อ่าน QR code ที่โต๊ะหรือบนโปสเตอร์, scan ใบงานเก็บเป็นรูป, อ่านเลขบนฉลากสินค้า

ข้อจำกัด:

- **Run บน iPad จริงเท่านั้น** Simulator ไม่มีกล้อง จึงเปิดหน้า scan ไม่ได้
- **ต้องได้สิทธิ์กล้อง** ถ้าผู้ใช้กดไม่อนุญาต หรือ Screen Time จำกัดกล้องไว้ `isAvailable` จะเป็น `false`
- **ต้องเป็นชิป A12 ขึ้นไป** iPad M chip ของงานผ่านทุกเครื่อง แต่ถ้าทีมเอาไปลงเครื่องเก่า ต้องเช็ก `isSupported`
- **ปรับหน้าตาได้น้อย** เป็นหน้าจอสำเร็จรูป เปลี่ยนสีกรอบหรือเพิ่มปุ่มได้บ้าง แต่จัด layout ใหม่ทั้งหมดไม่ได้
- **ภาษาที่อ่านได้ขึ้นกับเครื่อง** iPad ของงานอ่านภาษาไทยได้ แต่ถ้าเอา app ไปลงเครื่องอื่น ให้เช็กตาม[ปัญหาที่เจอบ่อย](#troubleshooting)

## Setup

ทั้งสองหน้าจอใช้กล้อง จึงต้องเพิ่มใน Info.plist

```text
NSCameraUsageDescription
    "ใช้กล้องเพื่อ scan ข้อความและเอกสาร"
```

## 1. อ่านข้อความและ QR สดจากกล้อง { #live-scanner }

`DataScannerViewController` เป็นหน้าจอแบบ UIKit จึงต้องห่อด้วย `UIViewControllerRepresentable` ก่อนใช้ใน SwiftUI ห่อครั้งเดียวแล้วใช้ได้ทุกที่ ไฟล์นี้อยู่ใน starter project ที่ `VisionParts/LiveScannerView.swift`

```swift
--8<-- "starter/workshop-5/Workshop5Starter/VisionParts/LiveScannerView.swift"
```

`recognizedDataTypes` บอกว่าจะให้หาอะไร ถ้าต้องการแค่ QR ให้ใส่ `.barcode(symbologies: [.qr])` อย่างเดียว เครื่องจะ scan เร็วขึ้น ข้อความที่เจอจะมีกรอบสีขึ้นบนจอ และเมื่อผู้ใช้แตะ เราจะได้ข้อความนั้นใน `onTap`

`LiveScannerView` เริ่ม scan เมื่อขึ้นบนจอ (`onAppear`) และหยุดเมื่อหายไป (`onDisappear`) เอง เพราะ `TabView` ไม่ทำลายแท็บที่ซ่อนอยู่ ถ้าไม่หยุดเอง สลับแท็บแล้วกลับมาจะ scan ไม่ติด `CameraView` ในหน้า [Hand pose](hand-pose.md) ก็ทำแบบเดียวกัน

!!! note "ภาษาไทย"
    iPad ของงานอ่านภาษาไทยได้ ต้องใส่ `"th-TH"` ใน `.text(languages:)` ไว้เสมอ ถ้าใส่แค่ `"en-US"` ตัวหนังสือไทยจะถูกข้ามหรืออ่านออกมาผิด

## 2. เช็กเครื่องก่อนเปิดหน้า scan

ไม่ใช่ทุกเครื่องที่ใช้ได้ และผู้ใช้อาจไม่ให้สิทธิ์กล้อง ให้ขอสิทธิ์และเช็กก่อนเสมอ app จะได้ไม่แสดงจอดำ

```swift
import AVFoundation
import SwiftUI
import VisionKit

struct ScanScreen: View {
    @State private var cameraAllowed = false
    @State private var result = ""

    var body: some View {
        VStack {
            if !DataScannerViewController.isSupported {
                ContentUnavailableView("เครื่องนี้ scan ไม่ได้", systemImage: "camera.slash")
            } else if cameraAllowed && DataScannerViewController.isAvailable {
                LiveScannerView { result = $0 }
            } else {
                ContentUnavailableView("ยังไม่ได้รับสิทธิ์กล้อง", systemImage: "camera.slash",
                    description: Text("เปิดได้ที่ Settings → ชื่อ app → Camera"))
            }
            Text(result).padding()
        }
        .task { cameraAllowed = await AVCaptureDevice.requestAccess(for: .video) }
    }
}
```

`requestAccess` ถามผู้ใช้แค่ครั้งแรก ครั้งต่อไปจะตอบทันทีตามที่ผู้ใช้เคยเลือก ส่วน `isSupported` = เครื่องนี้รองรับไหม (ต้องเป็นชิป A12 ขึ้นไป และ Simulator ไม่ผ่าน) และ `isAvailable` = ได้สิทธิ์กล้องแล้วและไม่ถูกจำกัดด้วย Screen Time

## 3. Scan เอกสาร { #document-camera }

`VNDocumentCameraViewController` คือหน้าจอ scan แบบแอป Notes: หาขอบกระดาษ ตัดและปรับมุมให้ตรงอัตโนมัติ scan ได้หลายหน้า แล้วส่งกลับมาเป็นรูป ไฟล์นี้อยู่ใน starter project ที่ `VisionParts/DocumentScannerView.swift`

```swift
--8<-- "starter/workshop-5/Workshop5Starter/VisionParts/DocumentScannerView.swift"
```

เปิดหน้านี้ด้วย `.fullScreenCover` แล้วปิดเองใน `onFinish`

```swift
.fullScreenCover(isPresented: $showScanner) {
    DocumentScannerView { pages in
        scannedPages = pages
        showScanner = false
    }
    .ignoresSafeArea()
}
```

รูปที่ได้ส่งต่อให้ [อ่านข้อความจากรูป](text-recognition.md) ได้ทันที

!!! danger "ใช้เอกสารตัวอย่างเท่านั้น"
    ห้าม scan บัตรประชาชน ใบสั่งยา หรือเอกสารจริงของคนอื่นตอน demo ใช้เอกสารที่ทำขึ้นเอง แม้ VisionKit จะประมวลผลบนเครื่อง แต่รูปที่ app บันทึกไว้หรือส่งต่อยังเป็นข้อมูลส่วนตัว

## ปัญหาที่เจอบ่อย { #troubleshooting }

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| App crash ทันทีที่เปิดกล้อง | ไม่มี `NSCameraUsageDescription` | เพิ่มใน Info.plist ดู [Setup](#setup) |
| จอดำ ไม่มีภาพ | Run บน Simulator หรือผู้ใช้ไม่ให้สิทธิ์กล้อง | Run บน iPad และเช็ก `isAvailable` ถ้าเคยกดไม่อนุญาต ให้เปิดใน Settings → ชื่อ app → Camera |
| เห็นภาพ แต่ไม่มีกรอบรอบข้อความ | ไม่ได้เรียก `startScanning()` | ดู `updateUIViewController` ในหัวข้อ 1 |
| สลับแท็บหรือหน้าจอแล้วกลับมา scan ไม่ติด | `TabView` ไม่ทำลายหน้าที่ซ่อนอยู่ scanner จึงไม่ถูกเริ่มใหม่ หรือกล้องถูกหน้าอื่นใช้อยู่ | ใช้ `LiveScannerView` และ `CameraView` เวอร์ชันล่าสุดจาก starter ซึ่งหยุดและเริ่มกล้องเองตอนหน้าจอหายและกลับมา |
| อ่านภาษาไทยไม่ได้ | ไม่ได้ใส่ `"th-TH"` หรือ run บนเครื่องอื่นที่ไม่รองรับ | พิมพ์ `DataScannerViewController.supportedTextRecognitionLanguages` ดูว่ามี `th-TH` ไหม |

## ใช้ร่วมกับ

- [อ่านข้อความจากรูป](text-recognition.md): อ่านข้อความจากหน้าที่ scan มา
- [Foundation Models](../workshop-2/foundation-models.md): ส่งข้อความที่ scan ได้ให้ model สรุป แปล หรือจัดเป็น `@Generable` struct

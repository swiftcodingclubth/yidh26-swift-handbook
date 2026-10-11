# VisionKit

!!! review "Comment ถึงผู้สอน"
    ปัญหาเรื่อง ภาษาที่อ่านได้ขึ้นกับเครื่อง อาจจะ specific เกินไป ผมว่าไม่จำเป็นต้องพูดถึง

**VisionKit** คือชุดหน้าจอสำเร็จรูปที่ Apple รวมกล้องกับ Vision ไว้ให้แล้ว แบบเดียวกับ Live Text ใน app Camera และการ scan เอกสารใน app Notes เราแค่เปิดหน้าจอแล้วรอรับผล ไม่ต้องจัดการกล้องหรือเรียก Vision เอง ใช้ได้ทั้ง Xcode 26 และ 27

ใช้ทำอะไรได้: อ่านเมนูหรือป้าย, อ่าน QR code ที่โต๊ะหรือบนโปสเตอร์, scan ใบงานเก็บเป็นรูป, อ่านเลขบนฉลากสินค้า

ข้อจำกัด:

- **Run บน iPad จริงเท่านั้น** Simulator ไม่มีกล้อง จึงเปิดหน้า scan ไม่ได้
- **ต้องได้สิทธิ์กล้อง** ถ้าผู้ใช้กดไม่อนุญาต หรือ Screen Time จำกัดกล้องไว้ `isAvailable` จะเป็น `false`
- **ต้องเป็นชิป A12 ขึ้นไป** iPad ของงานเป็นชิป M ทุกเครื่องจึงใช้ได้ แต่ถ้านำไปติดตั้งบนเครื่องรุ่นเก่า ต้องเช็ก `isSupported`
- **ปรับหน้าตาได้น้อย** เป็นหน้าจอสำเร็จรูป เปลี่ยนสีกรอบหรือเพิ่มปุ่มได้บ้าง แต่จัด layout ใหม่ทั้งหมดไม่ได้
- **ภาษาที่อ่านได้ขึ้นกับเครื่อง** iPad ของงานอ่านภาษาไทยได้ แต่ถ้านำ app ไปใช้กับเครื่องอื่น ให้เช็กตาม[ปัญหาที่เจอบ่อย](#troubleshooting)

## Setup

ทั้งสองหน้าจอใช้กล้อง จึงต้องเพิ่ม key นี้ใน Info.plist

```text
NSCameraUsageDescription
    "ใช้กล้องเพื่อ scan ข้อความและเอกสาร"
```

## 1. อ่านข้อความและ QR สดจากกล้อง { #live-scanner }

`DataScannerViewController` เป็นหน้าจอแบบ UIKit จึงต้องห่อด้วย `UIViewControllerRepresentable` ก่อนใช้ใน SwiftUI ห่อครั้งเดียวแล้วใช้ได้ทุกที่ ไฟล์นี้อยู่ใน starter project ที่ `VisionParts/LiveScannerView.swift`

```swift
--8<-- "starter/workshop-5/Workshop5Starter/VisionParts/LiveScannerView.swift"
```

`recognizedDataTypes` กำหนดว่าจะให้หาอะไร ถ้าต้องการแค่ QR ให้ใส่ `.barcode(symbologies: [.qr])` อย่างเดียว เครื่องจะ scan เร็วขึ้น ข้อความที่เจอจะมีกรอบสีขึ้นบนจอ และเมื่อผู้ใช้แตะที่กรอบ เราจะได้ข้อความนั้นใน `onTap`

`LiveScannerView` เริ่ม scan เองเมื่อแสดงบนจอ (`onAppear`) และหยุดเองเมื่อหายไป (`onDisappear`) ที่ต้องทำเช่นนี้เพราะ `TabView` ไม่ทำลายแท็บที่ซ่อนอยู่ ถ้าไม่หยุดเอง เมื่อสลับแท็บแล้วกลับมา scanner จะไม่ทำงาน `CameraView` ในหน้า [Hand pose](hand-pose.md) ก็ทำแบบเดียวกัน

!!! note "ภาษาไทย"
    iPad ของงานอ่านภาษาไทยได้ แต่ต้องใส่ `"th-TH"` ใน `.text(languages:)` ทุกครั้ง ถ้าใส่แค่ `"en-US"` ตัวหนังสือไทยจะถูกข้ามหรืออ่านออกมาผิด

## 2. เช็กเครื่องก่อนเปิดหน้า scan

ไม่ใช่ทุกเครื่องที่รองรับ และผู้ใช้อาจไม่ให้สิทธิ์กล้อง จึงควรขอสิทธิ์และเช็กก่อนทุกครั้ง เพื่อไม่ให้ app แสดงจอดำ

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

`requestAccess` ถามผู้ใช้แค่ครั้งแรก ครั้งต่อไปจะตอบทันทีตามที่ผู้ใช้เคยเลือก `isSupported` บอกว่าเครื่องนี้รองรับหรือไม่ (ต้องเป็นชิป A12 ขึ้นไป และใช้บน Simulator ไม่ได้) ส่วน `isAvailable` บอกว่าได้สิทธิ์กล้องแล้วและไม่ถูกจำกัดด้วย Screen Time

## 3. Scan เอกสาร { #document-camera }

`VNDocumentCameraViewController` คือหน้าจอ scan แบบ app Notes: หาขอบกระดาษ ตัดและปรับมุมให้ตรงอัตโนมัติ scan ได้หลายหน้า แล้วส่งกลับมาเป็นรูป ไฟล์นี้อยู่ใน starter project ที่ `VisionParts/DocumentScannerView.swift`

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

รูปที่ได้สามารถส่งต่อไป[อ่านข้อความจากรูป](text-recognition.md)ได้ทันที

## ปัญหาที่เจอบ่อย { #troubleshooting }

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| App crash ทันทีที่เปิดกล้อง | ไม่มี `NSCameraUsageDescription` | เพิ่มใน Info.plist ดู [Setup](#setup) |
| จอดำ ไม่มีภาพ | Run บน Simulator หรือผู้ใช้ไม่ให้สิทธิ์กล้อง | Run บน iPad และเช็ก `isAvailable` ถ้าเคยกดไม่อนุญาต ให้เปิดใน Settings → ชื่อ app → Camera |
| เห็นภาพ แต่ไม่มีกรอบรอบข้อความ | ไม่ได้เรียก `startScanning()` | ดู `updateUIViewController` ในหัวข้อ 1 |
| สลับแท็บหรือหน้าจอแล้วกลับมา scan ไม่ติด | `TabView` ไม่ทำลายหน้าที่ซ่อนอยู่ scanner จึงไม่ถูกเริ่มใหม่ หรือกล้องถูกหน้าอื่นใช้อยู่ | ใช้ `LiveScannerView` และ `CameraView` เวอร์ชันล่าสุดจาก starter ซึ่งจะหยุดกล้องเมื่อหน้าจอถูกซ่อน และเริ่มใหม่เมื่อกลับมาแสดง |
| อ่านภาษาไทยไม่ได้ | ไม่ได้ใส่ `"th-TH"` หรือ run บนเครื่องอื่นที่ไม่รองรับ | print ค่า `DataScannerViewController.supportedTextRecognitionLanguages` เพื่อดูว่ามี `th-TH` หรือไม่ |

## ใช้ร่วมกับ

- [อ่านข้อความจากรูป](text-recognition.md): อ่านข้อความจากหน้าที่ scan มา
- [Foundation Models](../workshop-2/foundation-models.md): ส่งข้อความที่ scan ได้ให้ model สรุป แปล หรือจัดเป็น `@Generable` struct

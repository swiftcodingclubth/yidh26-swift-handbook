# ใส่ใน app ของทีม

หน้านี้รวมสิ่งที่ต้องทำเพื่อย้าย feature จาก starter project ไปใส่ใน project ของทีม ทำตามลำดับ ใช้ได้ทั้ง Xcode 26 และ 27

## 0. ดาวน์โหลด starter project { #get-starter }

Starter project อยู่ในโฟลเดอร์ [`starter/workshop-5`](https://github.com/swiftcodingclubth/yidh26-swift-handbook/tree/main/starter/workshop-5) ของ repo handbook นี้

1. เปิด [repo handbook](https://github.com/swiftcodingclubth/yidh26-swift-handbook) กด **Code → Download ZIP** แล้วแตกไฟล์ (หรือใช้ `git clone` ก็ได้)
2. เปิด `starter/workshop-5/Workshop5Starter.xcodeproj`
3. เลือก target **Workshop5Starter** → **Signing & Capabilities** → เลือก **Team** ของตัวเอง แล้ว run บน iPad

## 1. Copy ไฟล์ { #files }

ไฟล์ทั้งหมดอยู่ในโฟลเดอร์ `VisionParts/` ของ starter project ลากเข้า Xcode project แล้วติ๊ก **Copy items if needed** และเลือก target ของ app

| Feature | ไฟล์ที่ต้อง copy |
|---|---|
| อ่านข้อความ / QR สด | `LiveScannerView.swift` |
| Scan เอกสาร | `DocumentScannerView.swift` |
| อ่านข้อความจากรูป | `TextReader.swift` |
| ท่ามือ | `CameraView.swift`, `HandReader.swift` |

ไฟล์แต่ละชุดไม่ขึ้นต่อกัน จึง copy เฉพาะชุดที่ต้องใช้ได้ ทุกไฟล์ build ผ่านทั้ง Swift 5 และ Swift 6 จึงใช้กับ project ที่ตั้งค่า concurrency แบบไหนก็ได้

## 2. Info.plist { #info-plist }

ใน Xcode เลือก target → แท็บ **Info** → กด + แล้วเพิ่ม key ต่อไปนี้

| Key | ต้องใช้เมื่อ | ตัวอย่างข้อความ |
|---|---|---|
| `Privacy - Camera Usage Description` (`NSCameraUsageDescription`) | ใช้กล้องทุกแบบ | "ใช้กล้องเพื่อ scan ข้อความ" |

ผู้ใช้จะเห็นข้อความนี้ตอนที่ app ขอสิทธิ์ จึงควรเขียนให้ชัดว่าใช้กล้องทำอะไร ส่วน `PhotosPicker` ไม่ต้องเพิ่ม key ใดๆ

## 3. Deployment target { #deployment-target }

Vision Swift API ต้องใช้ iOS 18 ขึ้นไป ดูที่ target → **General** → **Minimum Deployments** ถ้าตั้งไว้เป็น iOS 26 อยู่แล้ว ไม่ต้องแก้

## 4. เช็กเครื่องและสิทธิ์ก่อนใช้ { #checks }

- VisionKit: เช็ก `DataScannerViewController.isSupported && .isAvailable` หรือ `VNDocumentCameraViewController.isSupported` ก่อนแสดงหน้า scan
- ถ้าผู้ใช้ไม่อนุญาตให้ใช้กล้อง: ให้แสดงข้อความแนะนำให้ไปเปิดสิทธิ์ใน Settings แทนการแสดงจอดำ
- Feature ที่ใช้กล้อง (scan สด, scan เอกสาร, hand pose) ต้อง test บน iPad จริง ส่วนอ่านข้อความจากรูปลองบน Simulator ได้

## 5. ให้ agent ช่วย { #agent-prompts }

ใช้ template จาก [Workshop 1](../workshop-1/prompting.md) แล้วระบุไฟล์ที่ copy มาให้ชัด agent จะได้ไม่เขียนใหม่ด้วย API แบบเก่า

```text
Context: project นี้มี LiveScannerView.swift (VisionKit DataScannerViewController)
อยู่แล้ว และใช้ Vision Swift API แบบใหม่ (iOS 18+) ห้ามใช้ VNRecognizeTextRequest
Task: เพิ่มปุ่ม "Scan" ใน RecipeListView เปิด LiveScannerView ด้วย .sheet
เมื่อผู้ใช้แตะข้อความ ให้เพิ่มเป็น ingredient ใหม่ใน list แล้วปิด sheet
Constraints: ห้ามแก้ LiveScannerView.swift, ต้องเช็ก isSupported/isAvailable ก่อน
Done when: build ผ่าน และ run บน iPad แล้วเพิ่ม ingredient จากการ scan ได้
```

```text
Context: มี CameraView.swift และ HandReader.swift ที่หาตำแหน่งนิ้วด้วย
DetectHumanHandPoseRequest แล้ว
Task: เพิ่มท่า "thumbs up" ใน HandSign โดยดูจากตำแหน่ง thumbTip เทียบกับ wrist
และให้ทำงานเฉพาะเมื่อท่านิ่งติดต่อกัน 10 frame
Done when: build ผ่าน และยกนิ้วโป้งหน้ากล้องแล้วขึ้น 👍
```

## ปัญหาที่เจอบ่อย

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| `Cannot find 'LiveScannerView' in scope` | ไฟล์ไม่ได้อยู่ใน target ของ app | เลือกไฟล์ → File inspector → ติ๊ก target ใน **Target Membership** |
| `'RecognizeTextRequest' is only available in iOS 18.0 or newer` | Deployment target ต่ำเกินไป | ดู [Deployment target](#deployment-target) |
| Crash ตอนเปิดกล้องใน project ของทีม (ใน starter ไม่ crash) | Starter มี Info.plist key แต่ project ของทีมไม่มี | ดู [Info.plist](#info-plist) |
| `Enum case 'front' is not available due to missing import of defining module 'AVFoundation'` | ใช้ `CameraView(position: .front, …)` ในไฟล์ที่ไม่ได้ import AVFoundation | เพิ่ม `import AVFoundation` บนสุดของไฟล์นั้น |
| Agent เขียนโค้ดยาวด้วย `VNImageRequestHandler` | Agent ใช้ API แบบเก่า | บอกใน prompt ว่าใช้ Vision Swift API แบบใหม่ และใช้ไฟล์ที่มีอยู่แล้ว |

!!! danger "ข้อมูลจากกล้องเป็นข้อมูลส่วนบุคคล"
    Vision ประมวลผลบน iPad ไม่ส่งภาพออกนอกเครื่อง แต่ถ้า app บันทึกรูปหรือส่งข้อความที่อ่านได้ไปที่ AI cluster หรือ server ต้องแจ้งให้ผู้ใช้ทราบ

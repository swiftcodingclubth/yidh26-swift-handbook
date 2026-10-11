# Workshop 5 starter: Vision & VisionKit

Starter project ของ Workshop 5 · iOS 26 · ไม่มี dependency ภายนอก · เปิดได้ทั้ง Xcode 26 และ 27

## เริ่มใช้งาน

1. เปิด `Workshop5Starter.xcodeproj`
2. เลือก target **Workshop5Starter** → **Signing & Capabilities** → เลือก **Team** ของตัวเอง
3. เลือก iPad เป็น run destination แล้วกด Run

แท็บ Read ลองบน Simulator ได้ ส่วนแท็บอื่นต้องใช้กล้อง จึงต้อง run บน iPad จริง

## แท็บ

| แท็บ | ขั้น | เนื้อหา |
|---|---|---|
| Scan | 1 | VisionKit: scan ข้อความและ QR สด, scan เอกสาร |
| Read | 2 | Vision: อ่านข้อความจากรูปใน Photos หรือเอกสารที่ scan |
| Hand | 3 | Vision: จุดนิ้วมือจากกล้องสด → ค้อน กรรไกร กระดาษ |
| Game | demo | เป่ายิ้งฉุบกับ iPad |
| AI | ไปต่อ | ส่งรูปให้ Foundation Models + `OCRTool` / `BarcodeReaderTool` (ต้อง build ด้วย Xcode 27) |
| Languages | ผู้สอน | เช็กว่าเครื่องอ่านภาษาไทยได้ไหม |

## `VisionParts/`: ไฟล์ที่ copy ไปใส่ app ของทีมได้

ไฟล์ในโฟลเดอร์นี้ไม่พึ่งไฟล์อื่นใน project copy เฉพาะที่ใช้ได้ และ build ผ่านทั้ง Swift 5 และ Swift 6 ไม่ว่าจะตั้ง default actor isolation เป็น MainActor หรือ nonisolated

| Feature | ไฟล์ |
|---|---|
| อ่านข้อความ / QR สด | `LiveScannerView.swift` |
| Scan เอกสาร | `DocumentScannerView.swift` |
| อ่านข้อความจากรูป | `TextReader.swift` |
| ท่ามือ | `CameraView.swift`, `HandReader.swift` |

ทุก feature ที่ใช้กล้องต้องเพิ่ม `NSCameraUsageDescription` ใน Info.plist ของ app ด้วย (project นี้ตั้งไว้ใน build setting `INFOPLIST_KEY_NSCameraUsageDescription`)

## ตามไม่ทัน

ไฟล์ใน `VisionParts/` ทำงานครบทุกหัวข้อแล้ว copy ไปใส่ project ของทีมได้เลย ดูขั้นตอนใน handbook หน้า "ใส่ใน app ของทีม"

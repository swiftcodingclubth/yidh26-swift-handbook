# Give your app sight with Vision and VisionKit

Workshop นี้ทำให้ app ของทีม **มองเห็น**: อ่านข้อความจากกล้องหรือรูป, scan เอกสาร, อ่าน QR code และรู้ว่ามือของผู้ใช้กำลังทำท่าอะไร ทุกอย่างทำงานบน iPad โดยไม่ต้องต่อ internet และไม่ต้อง train model เอง

## สิ่งที่จะได้เรียน { #outcomes }

1. **Scan ด้วยหน้าจอสำเร็จรูปของ VisionKit**: อ่านข้อความและ QR code สดจากกล้อง และ scan เอกสารแบบ app Notes
2. **อ่านข้อความจากรูปด้วย Vision**: เข้าใจ pattern request → perform → observation ที่ใช้กับทุก request ของ Vision
3. **Track มือจากกล้อง**: หาตำแหน่งจุดบนมือ 21 จุด แล้วแปลงเป็นท่า เช่น ค้อน กรรไกร กระดาษ
4. **ใส่ feature เข้า app ของทีม**: รู้ว่าต้อง copy ไฟล์ไหน ต้องขอ permission อะไร และเช็กว่าเครื่องรองรับก่อนใช้

## แนวคิดหลัก { #concepts }

### Vision กับ VisionKit ต่างกันยังไง { #vision-vs-visionkit }

ชื่อคล้ายกัน แต่ทำงานคนละชั้น

- **Vision** คือ "สมอง" ที่วิเคราะห์รูป เราส่งรูปเข้าไป แล้วได้ข้อมูลกลับมา เช่น ข้อความ ตำแหน่งนิ้ว หรือ QR code ไม่มีหน้าจอให้ เราต้องหารูปเอง และวาดผลบนหน้าจอเอง
- **VisionKit** คือ "หน้าจอสำเร็จรูป" ที่ Apple รวมกล้องกับ Vision ไว้ให้แล้ว เราแค่เปิดหน้าจอแล้วรอรับผล

| | Vision | VisionKit |
|---|---|---|
| ได้อะไร | ข้อมูลจากรูป | หน้าจอ scan ที่พร้อมใช้ |
| รูปมาจากไหน | เราส่งให้เอง: รูปใน Photos หรือ frame จากกล้อง | กล้องที่อยู่ในหน้าจอนั้น |
| หน้าจอ | ออกแบบเองทั้งหมด | ปรับได้น้อย |
| โค้ดที่ต้องเขียน | มากกว่า แต่ทำได้หลายอย่าง | น้อย แต่ทำได้แค่ที่ Apple เตรียมไว้ |
| ใช้บน Simulator | ได้ ถ้าใช้รูปจาก Photos | ไม่ได้ ต้องใช้กล้อง |

เริ่มจาก VisionKit ก่อน ถ้าหน้าจอสำเร็จรูปทำได้ตรงกับที่ต้องการ ถ้าต้องอ่านรูปที่มีอยู่แล้ว หรืออยากได้ข้อมูลที่ VisionKit ไม่มี เช่น ตำแหน่งนิ้วมือ ให้ใช้ Vision

### เลือกเครื่องมือ

| ถ้าต้องการ… | ใช้ |
|---|---|
| ชี้กล้องแล้วอ่านข้อความหรือ QR สด | **VisionKit** `DataScannerViewController` |
| Scan เอกสารเป็นรูป ตัดขอบให้อัตโนมัติ | **VisionKit** `VNDocumentCameraViewController` |
| อ่านข้อความจากรูปที่มีอยู่แล้ว | **Vision** `RecognizeTextRequest` |
| รู้ตำแหน่งนิ้วมือหรือข้อต่อร่างกาย | **Vision** `DetectHumanHandPoseRequest` |
| จำแนกรูปตามหมวดที่เรากำหนดเอง | **Create ML** Image Classifier ดู [Workshop 3](../workshop-3/create-ml.md) |

### Pattern เดียวของ Vision

ทุก request ของ Vision ใช้ 3 ขั้นเหมือนกัน เปลี่ยนแค่ชนิดของ request

```swift
let request = RecognizeTextRequest()                 // 1. สร้าง request: อยากรู้อะไร
let observations = try await request.perform(on: image) // 2. perform กับรูป
for observation in observations { … }                // 3. อ่านผล (observation)
```

VisionKit ทำ 3 ขั้นนี้ให้อยู่ข้างในแล้ว เราจึงไม่ต้องเขียนเอง

## MacBook แต่ละเครื่องทำอะไรได้บ้าง { #machines }

ทั้ง {{ mac.apple }} และ {{ mac.intel }} ทำได้ครบทุกหัวข้อ เพราะ API ทั้งหมดมีมาตั้งแต่ Xcode 26 สิ่งที่ต้องระวังคือเครื่องที่ใช้ run: Simulator ไม่มีกล้อง หัวข้อที่ใช้กล้องจึงต้อง run บน iPad จริง

| หัวข้อ | Simulator | iPad จริง |
|---|:---:|:---:|
| [VisionKit](visionkit.md): scan ข้อความ/QR สด และ scan เอกสาร | ✗ | ✓ |
| [อ่านข้อความจากรูป](text-recognition.md): เลือกรูปจาก Photos | ✓ | ✓ |
| [Hand pose](hand-pose.md): จากกล้องสด | ✗ | ✓ |

ดูข้อจำกัดอื่นได้ที่ต้นหน้าของแต่ละหัวข้อ

!!! mchip "{{ mac.apple }} · Xcode 27"
    ทำได้เพิ่มอีก 1 อย่าง คือส่งรูปให้ Foundation Models อ่านและสรุปเอง (API ของ iOS 27) เนื้อหานี้ไม่อยู่ใน session หลัก ดูได้ในส่วน "ไปต่อ" ของหน้า[อ่านข้อความจากรูป](text-recognition.md#next)

## หัวข้อหลัก { #pages }

อ่านตามลำดับนี้จะเข้าใจง่ายที่สุด

| หน้า | เนื้อหา |
|---|---|
| [VisionKit](visionkit.md) | อ่านข้อความและ QR สดจากกล้อง และ scan เอกสาร |
| [อ่านข้อความจากรูป](text-recognition.md) | ใช้ `RecognizeTextRequest` กับรูปจาก Photos หรือเอกสารที่ scan มา |
| [Hand pose](hand-pose.md) | หาตำแหน่งนิ้วจากกล้องสด แล้วแปลงเป็นท่ามือ |
| [ใส่ใน app ของทีม](add-to-your-app.md) | ไฟล์ที่ต้อง copy, Info.plist, เช็กเครื่อง และ prompt สำหรับ agent |

## ลงมือปฏิบัติ { #hands-on }

Starter project อยู่ในโฟลเดอร์ [`starter/workshop-5`](https://github.com/swiftcodingclubth/yidh26-swift-handbook/tree/main/starter/workshop-5) ของ repo handbook นี้ ดูวิธีเอามาใช้ใน[ใส่ใน app ของทีม](add-to-your-app.md#get-starter)

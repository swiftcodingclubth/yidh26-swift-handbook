# Give your app sight with Vision and VisionKit

Workshop นี้ทำให้ app ของทีม **มองเห็น**: อ่านข้อความจากกล้องหรือรูป, scan เอกสาร, อ่าน QR code และรู้ว่ามือของผู้ใช้กำลังทำท่าอะไร ทุกอย่าง run บน iPad ไม่ต้องใช้ internet และไม่ต้อง train model เอง

Workshop นี้เป็นส่วนเสริม แต่ละหัวข้อเป็นชิ้นส่วนที่ copy ไปใส่ app ของทีมได้เลย ถ้าท่าทางที่ต้องการซับซ้อนกว่านับนิ้ว ให้ต่อด้วยการ train model ใน [Workshop 3](../workshop-3/create-ml.md)

## สิ่งที่จะได้เรียน { #outcomes }

1. **Scan ด้วยหน้าจอสำเร็จรูปของ VisionKit**: อ่านข้อความและ QR code สดจากกล้อง และ scan เอกสารแบบแอป Notes
2. **อ่านข้อความจากรูปด้วย Vision**: เข้าใจ pattern request → perform → observation ที่ใช้กับทุก request ของ Vision
3. **Track มือจากกล้อง**: หาตำแหน่งข้อนิ้ว 21 จุด แล้วแปลงเป็นท่า เช่น ค้อน กรรไกร กระดาษ
4. **ใส่ feature เข้า app ของทีม**: รู้ว่าต้อง copy ไฟล์ไหน ต้องขอ permission อะไร และเช็กว่าเครื่องรองรับก่อนใช้

## แนวคิดหลัก { #concepts }

### เลือกเครื่องมือ

| ถ้าต้องการ… | ใช้ | เขียนโค้ด |
|---|---|---|
| ชี้กล้องแล้วอ่านข้อความหรือ QR สด | **VisionKit** `DataScannerViewController` | น้อยมาก |
| Scan เอกสารเป็นรูป ตัดขอบให้อัตโนมัติ | **VisionKit** `VNDocumentCameraViewController` | น้อยมาก |
| อ่านข้อความจากรูปที่มีอยู่แล้ว | **Vision** `RecognizeTextRequest` | ปานกลาง |
| รู้ตำแหน่งนิ้วมือหรือข้อต่อร่างกาย | **Vision** `DetectHumanHandPoseRequest` | ปานกลาง |
| แยกประเภทรูปแบบที่เรากำหนดเอง | **Create ML** Image Classifier | ดู [Workshop 3](../workshop-3/create-ml.md) |

### Pattern เดียวของ Vision

ทุก request ของ Vision ใช้ 3 ขั้นเหมือนกัน เปลี่ยนแค่ชนิดของ request

```swift
let request = RecognizeTextRequest()                 // 1. สร้าง request: อยากรู้อะไร
let observations = try await request.perform(on: image) // 2. perform กับรูป
for observation in observations { … }                // 3. อ่านผล (observation)
```

VisionKit คือหน้าจอที่ Apple ห่อ Vision กับกล้องไว้ให้แล้ว จึงไม่ต้องเขียน 3 ขั้นนี้เอง

## MacBook แต่ละเครื่องทำอะไรได้บ้าง { #machines }

ทำได้ครบทั้ง {{ mac.apple }} และ {{ mac.intel }} เพราะทุกอย่างใน workshop นี้มีตั้งแต่ Xcode 26 ส่วนที่ต่างกันคือเครื่องที่ใช้ run: Simulator ไม่มีกล้อง ส่วนที่ใช้กล้องจึงต้อง run บน iPad จริง

| หัวข้อ | Simulator | iPad จริง |
|---|:---:|:---:|
| [VisionKit](visionkit.md): scan ข้อความ/QR สด และ scan เอกสาร | ✗ | ✓ |
| [อ่านข้อความจากรูป](text-recognition.md): เลือกรูปจาก Photos | ✓ | ✓ |
| [Hand pose](hand-pose.md): จากกล้องสด | ✗ | ✓ |

ข้อจำกัดอื่นของแต่ละหัวข้ออยู่ใต้ย่อหน้าแรกของแต่ละหน้า

!!! mchip "{{ mac.apple }} · Xcode 27"
    ทำได้เพิ่มอีกอย่างเดียว คือส่งรูปให้ Foundation Models อ่านและสรุปเอง ซึ่งเป็น API ของ iOS 27 อยู่ใน "ไปต่อ" ของ[อ่านข้อความจากรูป](text-recognition.md#next) ไม่ได้อยู่ในเนื้อหาหลักของ session

## หัวข้อหลัก { #pages }

อ่านตามลำดับนี้จะเข้าใจง่ายที่สุด

| หน้า | เนื้อหา |
|---|---|
| [VisionKit](visionkit.md) | อ่านข้อความและ QR สดจากกล้อง และ scan เอกสาร |
| [อ่านข้อความจากรูป](text-recognition.md) | ใช้ `RecognizeTextRequest` กับรูปจาก Photos หรือเอกสารที่ scan มา |
| [Hand pose](hand-pose.md) | หาตำแหน่งนิ้วจากกล้องสด แล้วแปลงเป็นท่ามือ |
| [ใส่ใน app ของทีม](add-to-your-app.md) | ไฟล์ที่ต้อง copy, Info.plist, เช็กเครื่อง และ prompt สำหรับ agent |

## ลงมือปฏิบัติ { #hands-on }

Starter project อยู่ในโฟลเดอร์ [`starter/workshop-5`](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-5) ของ repo handbook นี้ ดูวิธีเอามาใช้ใน[ใส่ใน app ของทีม](add-to-your-app.md#get-starter)

เลือก 1 track ที่ตรงกับ idea ของทีม แล้วใส่ลง app ของทีมจริง ถ้ายังไม่อยากแก้ project ให้ทำ "ภารกิจเสริม" ใน [Hand pose](hand-pose.md#extra) บน starter project แทน

### Track: Scan & อ่าน

App ที่ต้องรับข้อมูลจากของจริง เช่น อ่านเมนู อ่านฉลาก อ่าน QR ที่โต๊ะ

1. **Copy ไฟล์** `LiveScannerView.swift` หรือ `DocumentScannerView.swift` เข้า project ดู [ไฟล์ที่ต้อง copy](add-to-your-app.md#files)
2. **เพิ่ม permission กล้อง** ใน Info.plist ดู [Info.plist](add-to-your-app.md#info-plist)
3. **เปิดหน้า scan** จากหน้าจอของทีมด้วย `.sheet` หรือ `.fullScreenCover` ดู [VisionKit](visionkit.md)
4. **เอาผลไปใช้ต่อ** เช่น บันทึกลง list ของ app หรือส่งให้ Foundation Models สรุป
5. **Test บน iPad** ทั้งตอนที่เครื่องรองรับ และตอนที่ผู้ใช้ไม่ให้สิทธิ์กล้อง

### Track: อ่านข้อความจากรูป

App ที่มีรูปอยู่แล้ว เช่น สมุดจด, รูปกระดาน, ใบงาน

1. **Copy ไฟล์** `TextReader.swift` และ `DocumentScannerView.swift` ถ้าจะให้ scan เอกสารได้ด้วย ดู [ไฟล์ที่ต้อง copy](add-to-your-app.md#files)
2. **ให้ผู้ใช้เลือกรูป** ด้วย `PhotosPicker` หรือ scan ด้วย Document Camera ดู [เลือกรูป](text-recognition.md#pick-photo)
3. **อ่านข้อความ** แล้วแสดงใน UI ดู [อ่านข้อความ](text-recognition.md#read)
4. **ทำให้ข้อความใช้งานได้** เช่น ค้นหา, copy, หรือแยกเป็นรายการ

### Track: ท่ามือ

App ที่ควบคุมด้วยมือ เช่น เกม, นับนิ้วสอนเลข, สั่ง app โดยไม่ต้องแตะจอ

1. **Copy ไฟล์** `CameraView.swift` และ `HandReader.swift` ดู [ไฟล์ที่ต้อง copy](add-to-your-app.md#files)
2. **เพิ่ม permission กล้อง** ดู [Info.plist](add-to-your-app.md#info-plist)
3. **แสดงจุดนิ้วบนจอ** ให้เห็นว่า Vision เจอมือ ดู [วาดจุดนิ้ว](hand-pose.md#draw)
4. **กำหนดท่าของทีมเอง** จากตำแหน่งนิ้ว ดู [แปลงเป็นท่า](hand-pose.md#gesture)
5. **ทำให้ท่านิ่ง** ไม่กระพริบ ก่อนให้ app ทำ action ดู [ทำให้ผลนิ่ง](hand-pose.md#smoothing)

!!! tip "ตามไม่ทัน"
    ไฟล์ในโฟลเดอร์ `VisionParts/` ของ starter project ทำงานครบทั้ง 3 หัวข้อแล้ว copy ไปใช้ได้เลย หรือใช้ prompt ใน [ใส่ใน app ของทีม](add-to-your-app.md#agent-prompts) ให้ agent ช่วย

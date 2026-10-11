# Give your app sight with Vision and VisionKit

!!! review "Comment ถึงผู้สอน"
    อยากให้เนื้อหาพูดถึงความแตกต่างของ Vision และ VisionKit ด้วย
Workshop นี้ทำให้ app ของทีม **มองเห็น**: อ่านข้อความจากกล้องหรือรูป, scan เอกสาร, อ่าน QR code และรู้ว่ามือของผู้ใช้กำลังทำท่าอะไร ทุกอย่างทำงานบน iPad โดยไม่ต้องต่อ internet และไม่ต้อง train model เอง

## สิ่งที่จะได้เรียน { #outcomes }

1. **Scan ด้วยหน้าจอสำเร็จรูปของ VisionKit**: อ่านข้อความและ QR code สดจากกล้อง และ scan เอกสารแบบ app Notes
2. **อ่านข้อความจากรูปด้วย Vision**: เข้าใจ pattern request → perform → observation ที่ใช้กับทุก request ของ Vision
3. **Track มือจากกล้อง**: หาตำแหน่งจุดบนมือ 21 จุด แล้วแปลงเป็นท่า เช่น ค้อน กรรไกร กระดาษ
4. **ใส่ feature เข้า app ของทีม**: รู้ว่าต้อง copy ไฟล์ไหน ต้องขอ permission อะไร และเช็กว่าเครื่องรองรับก่อนใช้

## แนวคิดหลัก { #concepts }

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

VisionKit คือหน้าจอที่ Apple ห่อ Vision กับกล้องไว้ให้แล้ว จึงไม่ต้องเขียน 3 ขั้นนี้เอง

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

Starter project อยู่ในโฟลเดอร์ [`starter/workshop-5`](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-5) ของ repo handbook นี้ ดูวิธีเอามาใช้ใน[ใส่ใน app ของทีม](add-to-your-app.md#get-starter)

!!! review "Comment ถึงผู้สอน"
    ผมคิดว่าลงมือปฏิบัติไม่ควรต้อง depend กับโปรเจคหลักของนักเรียน

เลือก 1 track ที่ตรงกับ idea ของทีม แล้วใส่ลงใน app จริงของทีม ถ้ายังไม่พร้อมแก้ project ของทีม ให้ทำ "ภารกิจเสริม" ใน [Hand pose](hand-pose.md#extra) บน starter project แทน

### Track: Scan & อ่าน

App ที่ต้องรับข้อมูลจากสิ่งรอบตัว เช่น อ่านเมนู อ่านฉลาก อ่าน QR code บนโต๊ะ

1. **Copy ไฟล์** `LiveScannerView.swift` หรือ `DocumentScannerView.swift` เข้า project ดู [ไฟล์ที่ต้อง copy](add-to-your-app.md#files)
2. **เพิ่ม permission กล้อง** ใน Info.plist ดู [Info.plist](add-to-your-app.md#info-plist)
3. **เปิดหน้า scan** จากหน้าจอของทีมด้วย `.sheet` หรือ `.fullScreenCover` ดู [VisionKit](visionkit.md)
4. **นำผลไปใช้ต่อ** เช่น บันทึกลง list ของ app หรือส่งให้ Foundation Models สรุป
5. **Test บน iPad** ทั้งตอนที่เครื่องรองรับ และตอนที่ผู้ใช้ไม่ให้สิทธิ์กล้อง

### Track: อ่านข้อความจากรูป

App ที่มีรูปอยู่แล้ว เช่น รูปถ่ายสมุดโน้ต รูปกระดาน ใบงาน

1. **Copy ไฟล์** `TextReader.swift` (และ `DocumentScannerView.swift` ถ้าต้องการให้ scan เอกสารได้ด้วย) ดู [ไฟล์ที่ต้อง copy](add-to-your-app.md#files)
2. **ให้ผู้ใช้เลือกรูป** ด้วย `PhotosPicker` หรือ scan ด้วย Document Camera ดู [เลือกรูป](text-recognition.md#pick-photo)
3. **อ่านข้อความ** แล้วแสดงใน UI ดู [อ่านข้อความ](text-recognition.md#read)
4. **นำข้อความไปใช้ต่อ** เช่น ค้นหา คัดลอก หรือแยกเป็นรายการ

### Track: ท่ามือ

App ที่ควบคุมด้วยมือ เช่น เกม, นับนิ้วสอนเลข, สั่ง app โดยไม่ต้องแตะจอ

1. **Copy ไฟล์** `CameraView.swift` และ `HandReader.swift` ดู [ไฟล์ที่ต้อง copy](add-to-your-app.md#files)
2. **เพิ่ม permission กล้อง** ดู [Info.plist](add-to-your-app.md#info-plist)
3. **แสดงจุดนิ้วบนจอ** ให้เห็นว่า Vision เจอมือ ดู [วาดจุดนิ้ว](hand-pose.md#draw)
4. **กำหนดท่าของทีมเอง** จากตำแหน่งนิ้ว ดู [แปลงเป็นท่า](hand-pose.md#gesture)
5. **ทำให้ผลนิ่ง** ไม่กะพริบ ก่อนให้ app ทำ action ดู [ทำให้ผลนิ่ง](hand-pose.md#smoothing)

!!! tip "ตามไม่ทัน"
    ไฟล์ในโฟลเดอร์ `VisionParts/` ของ starter project ทำงานครบทั้ง 3 หัวข้อแล้ว copy ไปใช้ได้เลย หรือใช้ prompt ใน [ใส่ใน app ของทีม](add-to-your-app.md#agent-prompts) ให้ agent ช่วย

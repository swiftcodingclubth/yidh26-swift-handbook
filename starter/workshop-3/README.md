# Workshop 3 starter: Core Motion, Sound, LiDAR & Core ML

Starter project ของ Workshop 3 · iOS 26 · ไม่มี dependency ภายนอก · เปิดได้ทั้ง Xcode 26 และ 27

ใช้เฉพาะโค้ดจากหน้า **Core Motion**, **Sound recognition**, **LiDAR** และ **Core ML** ใน handbook ไม่มีอะไรเพิ่ม ทุกหน้าจอเริ่มทำงานเมื่อเปิดหน้า และหยุดเมื่อออกจากหน้า (`onDisappear`) เพื่อไม่ให้ sensor ไมโครโฟน หรือกล้องเปิดค้าง

## เริ่มใช้งาน

1. เปิด `Workshop3Starter.xcodeproj`
2. เลือก target **Workshop3Starter** → **Signing & Capabilities** → เลือก **Team** ของตัวเอง
3. เลือก iPad เป็น run destination แล้วกด Run

| หน้า | ลองบน Simulator ได้ไหม |
|---|---|
| Core Motion | ไม่ได้ Simulator ไม่มี sensor การเคลื่อนไหว ต้อง run บน iPad จริง |
| Sound | ได้ Simulator ใช้ไมโครโฟนของ Mac |
| LiDAR | ไม่ได้ ต้องใช้ iPad Pro หรือ iPhone Pro จริง เครื่องอื่นจะขึ้นข้อความว่าไม่มี LiDAR |
| Core ML | GesturePredictor ไม่ได้ (ใช้ข้อมูลการเคลื่อนไหว) ส่วน "ในรูปมีอะไร?" ได้ ลากรูปไปวางบน Simulator เพื่อเพิ่มเข้า Photos |

## ไฟล์

| ไฟล์ | มีอะไร |
|---|---|
| `Motion.swift` | โค้ดจากหน้า Core Motion: `startMotionUpdates`, `stopMotionUpdates`, `detectGesture`, `MotionWindow`, `startAltitudeUpdates` |
| `Sound.swift` | โค้ดจากหน้า Sound recognition: `SoundListener` |
| `Lidar.swift` | โค้ดจากหน้า LiDAR: `hasLiDAR`, `DepthReader` |
| `Gesture.swift` | โค้ดจากหน้า Core ML: `GesturePredictor` |
| `GestureClassifier.mlmodel` | Activity Classifier ท่า `shake`, `tilt`, `circle`, `idle` (window 100 ที่ 50 Hz) |
| `ImageClassifier.swift` | โค้ดจากหน้า Core ML: `ImageClassifier` |
| `MobileNetV2.mlmodel` | model จำแนกรูปภาพสำเร็จรูปจาก [Apple](https://developer.apple.com/machine-learning/models/) (MobileNetV2FP16) ไม่ต้อง train |
| `UseCases/Motion/` | หน้าจอ Core Motion |
| `UseCases/Sound/` | หน้าจอ Sound recognition |
| `UseCases/LiDAR/` | หน้าจอ LiDAR |
| `UseCases/CoreML/` | หน้าจอ Core ML |

## Use case: Core Motion

| Use case | ลองทำ | ใช้ค่าอะไร | หัวข้อใน handbook |
|---|---|---|---|
| **MotionView** | เหวี่ยง iPad ซ้าย-ขวา ขึ้น-ลง เข้า-ออก ดูแถบแต่ละแกนขยับ | `userAcceleration.x`, `.y`, `.z` | อ่านข้อมูลการเคลื่อนไหว |
| **AttitudeView** | วาง iPad ราบ แล้วพยักหน้า เอียงคอ ส่ายหน้า | `attitude.pitch`, `.roll`, `.yaw` | มุมของเครื่อง: roll, pitch, yaw |
| **เอียงหรือไม่เอียง?** | วาง iPad ราบบนโต๊ะ เส้นเขียว = โต๊ะไม่เอียง | `attitude.roll` | มุมของเครื่อง: roll, pitch, yaw |
| **เขย่าสุ่มเมนู** | เขย่าแรงๆ ได้เมนูมื้อเที่ยงแบบสุ่ม | `detectGesture` | ตรวจจับท่าแบบง่ายโดยไม่ใช้ ML |
| **นับชั้น** | ถือ iPad เดินขึ้นหรือลงบันได | `CMAltimeter` | Barometer |

## Use case: Sound recognition

| Use case | ลองทำ | ใช้อะไร | หัวข้อใน handbook |
|---|---|---|---|
| **SoundView** | พูด ปรบมือ เคาะโต๊ะ ดูว่า classifier ตอบว่าอะไร | `SoundListener` | ฟังและจดจำเสียง |
| **รายชื่อเสียงที่รู้จัก** | ค้นหาชื่อเสียงที่ app ต้องใช้ เช่น `dog`, `bell` | `knownClassifications` | ดูรายชื่อเสียงที่รู้จัก |
| **แจ้งเตือนเสียงสำคัญ** | เปิดคลิปเสียงกริ่งหรือเด็กร้องจากอีกเครื่อง จอจะขึ้นสีแดงพร้อมข้อความ | เสียงที่สนใจ + ความมั่นใจเกิน 0.7 | ปรับให้แม่นขึ้น |

## Use case: LiDAR

| Use case | ลองทำ | ใช้อะไร | หัวข้อใน handbook |
|---|---|---|---|
| **DepthView** | หันกล้องหลังไปที่สิ่งของ แล้วเดินเข้าใกล้หรือถอยออก | `DepthReader` | วัดระยะที่จุดกลางจอ |
| **เตือนสิ่งกีดขวาง** | เดินเข้าหากำแพงช้าๆ จอเปลี่ยนจากเขียว → ส้ม → แดง | `DepthReader` + เงื่อนไขระยะ | วัดระยะที่จุดกลางจอ |

## Use case: Core ML

| Use case | ลองทำ | ใช้อะไร | หัวข้อใน handbook |
|---|---|---|---|
| **GesturePredictor** | ทำท่า shake, tilt, circle หรือถือนิ่ง จอจะขึ้นชื่อท่าที่ทำอยู่และความมั่นใจ เปลี่ยนทุก 1 วินาที | `MotionWindow` + `GesturePredictor` | ส่งข้อมูลสดให้ model |
| **ในรูปมีอะไร?** | เลือกรูปสัตว์ อาหาร หรือสิ่งของ แล้วดูว่า model บอกว่าอะไร | `ImageClassifier` + MobileNetV2 | ใช้ model สำเร็จรูปจาก Apple |

### ใช้ model ของทีมแทน

1. อัดท่าด้วย Motion Recorder แล้ว train ใน Create ML ตามหน้า Create ML
2. Export เป็นชื่อ `GestureClassifier.mlmodel` แล้วลากไปแทนไฟล์เดิมในโฟลเดอร์ `Workshop3Starter`
3. ถ้า train ด้วย 6 column เดิม (`accelX` … `rotationZ`) ไม่ต้องแก้โค้ด ถ้าเปลี่ยน column ต้องแก้ `GestureClassifierInput(...)` ใน `Gesture.swift` ให้ตรงกับแท็บ Predictions ของ model

## อัดข้อมูลให้ Create ML

ใช้ app แยก [`starter/workshop-3-recorder`](../workshop-3-recorder) อัดท่าทางแล้วส่งเป็น `MotionData.zip` ที่แยก folder ตามชื่อท่าไว้แล้ว

## ลองแก้เอง

- เปลี่ยน `2.0` ใน `detectGesture` ให้เขย่าเบาลงหรือแรงขึ้น
- เอียงหรือไม่เอียง: เปลี่ยน `1` องศาใน `isLevel` ให้เข้มงวดขึ้นหรือหลวมขึ้น
- เพิ่มเมนูของตัวเองใน `menus`
- แจ้งเตือนเสียงสำคัญ: เปิดหน้ารายชื่อเสียง หาเสียงที่อยากให้แจ้ง (เช่น `dog_bark`, `knock`) แล้วเพิ่มใน `important`
- ลดหรือเพิ่ม `0.7` แล้วดูว่าแจ้งเตือนผิดบ่อยขึ้นหรือพลาดบ่อยขึ้น
- เตือนสิ่งกีดขวาง: เปลี่ยนระยะ `0.5` และ `1.0` เมตร ให้เตือนเร็วขึ้นหรือช้าลง

## Permission

| ใช้อะไร | Key ใน Info.plist | Build setting ใน project นี้ |
|---|---|---|
| `CMAltimeter` (หน้านับชั้น) | `NSMotionUsageDescription` | `INFOPLIST_KEY_NSMotionUsageDescription` |
| ไมโครโฟน (หน้า Sound) | `NSMicrophoneUsageDescription` | `INFOPLIST_KEY_NSMicrophoneUsageDescription` |
| กล้อง (หน้า LiDAR) | `NSCameraUsageDescription` | `INFOPLIST_KEY_NSCameraUsageDescription` |

ตั้งไว้แล้วทั้งหมด ถ้าคัดลอกโค้ดไปใช้ใน project อื่นต้องใส่ key เหล่านี้ด้วย ไม่อย่างนั้น app จะ crash

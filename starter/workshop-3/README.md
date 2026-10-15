# Workshop 3 starter: Sensors & Core ML

Starter project ของ Workshop 3 · iOS 26 · ไม่มี dependency ภายนอก · เปิดได้ทั้ง Xcode 26 และ 27

ใช้เฉพาะโค้ดจากหน้า Core Motion, Sound recognition, LiDAR และ Core ML ใน handbook ทุกหน้าจอเริ่มใช้ sensor เมื่อเปิดหน้า และหยุดเมื่อออกจากหน้า เพื่อไม่ให้ sensor ไมโครโฟน หรือกล้องเปิดค้าง

## เริ่มใช้งาน

1. เปิด `Workshop3Starter.xcodeproj`
2. เลือก target **Workshop3Starter** → **Signing & Capabilities** → เลือก **Team** ของตัวเอง
3. เลือก iPad เป็น run destination แล้วกด Run

แท็บ Sound และหน้าที่ใช้รูปในแท็บ Core ML ลองบน Simulator ได้ ส่วนอื่นใช้ sensor จริง จึงต้อง run บน iPad

## แท็บ

| แท็บ | ขั้น | เนื้อหา | ลองบน Simulator |
|---|---|---|---|
| Motion | 1 | Core Motion: การเคลื่อนไหว มุมเอียง ท่าแบบง่าย barometer | ไม่ได้ |
| Sound | 2 | Sound Analysis: จดจำเสียงด้วย classifier ในตัว | ได้ (ใช้ไมโครโฟนของ Mac) |
| LiDAR | 3 | ARKit: วัดระยะด้วยข้อมูลความลึก | ไม่ได้ (iPad Pro เท่านั้น) |
| Core ML | 4 | Run model ที่ train เอง และ model สำเร็จรูปจาก Apple (MobileNetV2, YOLOv3) | ได้เฉพาะหน้าที่ใช้รูป |

ขั้น Create ML (อัดท่าทางเพื่อ train) ใช้ app แยกใน [`starter/workshop-3-recorder`](../workshop-3-recorder) อัดแล้วส่งเป็น `MotionData.zip` ที่แยก folder ตามชื่อท่าไว้แล้ว

### 1. Motion

| หน้า | ลองทำ | หัวข้อใน handbook |
|---|---|---|
| **MotionView** | เหวี่ยง iPad ซ้าย-ขวา ขึ้น-ลง เข้า-ออก ดูแถบแต่ละแกนขยับ | อ่านข้อมูลการเคลื่อนไหว |
| **AttitudeView** | วาง iPad ราบ แล้วพยักหน้า เอียงคอ ส่ายหน้า | มุมของเครื่อง: roll, pitch, yaw |
| **เอียงหรือไม่เอียง?** | วาง iPad ราบบนโต๊ะ เส้นเขียว = โต๊ะไม่เอียง | มุมของเครื่อง: roll, pitch, yaw |
| **เขย่าสุ่มเมนู** | เขย่าแรงๆ ได้เมนูมื้อเที่ยงแบบสุ่ม | ตรวจจับท่าแบบง่ายโดยไม่ใช้ ML |
| **นับชั้น** | ถือ iPad เดินขึ้นหรือลงบันได | Barometer |

### 2. Sound

| หน้า | ลองทำ | หัวข้อใน handbook |
|---|---|---|
| **SoundView** | พูด ปรบมือ เคาะโต๊ะ ดูว่า classifier ตอบว่าอะไร | ฟังและจดจำเสียง |
| **รายชื่อเสียงที่รู้จัก** | ค้นหาชื่อเสียงที่ app ต้องใช้ เช่น `dog`, `bell` | ดูรายชื่อเสียงที่รู้จัก |
| **แจ้งเตือนเสียงสำคัญ** | เปิดคลิปเสียงกริ่งหรือเด็กร้องจากอีกเครื่อง จอจะขึ้นสีแดงพร้อมข้อความ | ปรับให้แม่นขึ้น |

### 3. LiDAR

| หน้า | ลองทำ | หัวข้อใน handbook |
|---|---|---|
| **DepthView** | หันกล้องหลังไปที่สิ่งของ แล้วเดินเข้าใกล้หรือถอยออก | วัดระยะที่จุดกลางจอ |
| **เตือนสิ่งกีดขวาง** | เดินเข้าหากำแพงช้าๆ จอเปลี่ยนจากเขียว → ส้ม → แดง | วัดระยะที่จุดกลางจอ |

### 4. Core ML

| หน้า | ลองทำ | หัวข้อใน handbook |
|---|---|---|
| **GesturePredictor** | กด **เริ่มทำท่า** ทำท่า shake, tilt, circle หรือถือนิ่งอย่างน้อย 2 วินาที แล้วกด **หยุดและทาย** | ทายท่าด้วย model |
| **วันนี้รู้สึกอย่างไร** | พิมพ์ความรู้สึกเป็นภาษาอังกฤษ emoji และสีพื้นหลังเปลี่ยนตามอารมณ์ ยิ่งมั่นใจสียิ่งเข้ม ถ้ามั่นใจไม่ถึง 40% จะขึ้น 🤔 | (ยังไม่มีใน handbook) |
| **ในรูปมีอะไร?** | เลือกรูปสัตว์ อาหาร หรือสิ่งของ แล้วดูว่า model บอกว่าอะไร | ใช้ model สำเร็จรูปจาก Apple |
| **หาวัตถุในรูป** | เลือกรูปที่มีหลายอย่างในฉาก เช่น คนกับสุนัข ถนน จะเห็นกรอบรอบวัตถุทุกชิ้นพร้อมจำนวน | หาวัตถุในรูปด้วย YOLOv3 |

## `SensorParts/`: ไฟล์ที่ copy ไปใส่ app ของทีมได้

ไฟล์ในโฟลเดอร์นี้คือโค้ดในหน้า handbook แต่ละชุดไม่ขึ้นต่อชุดอื่น จึง copy เฉพาะชุดที่ต้องใช้ได้

| Feature | ไฟล์ |
|---|---|
| การเคลื่อนไหว, มุมเอียง, ท่าแบบง่าย, barometer | `Motion.swift` |
| จดจำเสียง | `Sound.swift` |
| วัดระยะด้วย LiDAR | `Lidar.swift` |
| ทายท่าด้วย model ที่ train เอง | `Motion.swift`, `Gesture.swift`, `GestureClassifier.mlmodel` (หรือ model ของทีม) |
| บอกว่าในรูปมีอะไร | `ImageClassifier.swift`, `MobileNetV2.mlmodel` |
| หาวัตถุในรูปพร้อมตำแหน่ง | `ObjectDetector.swift`, `YOLOv3Tiny.mlmodel` |
| อารมณ์จากข้อความ (ภาษาอังกฤษ) | `TextEmotion.swift`, `EmotionClassifier.mlmodel` |

Build ผ่านใน project ที่ตั้ง **Swift Language Version เป็น Swift 5** (ค่าเริ่มต้นของ project ใหม่ใน Xcode 26) ไม่ว่าจะตั้ง Default Actor Isolation เป็น MainActor หรือ nonisolated

### Model

| ไฟล์ | มาจากไหน |
|---|---|
| `GestureClassifier.mlmodel` | Activity Classifier ท่า `shake`, `tilt`, `circle`, `idle` train จากข้อมูลของ Motion Recorder (window 100 ที่ 50 Hz, 6 column `accelX` … `rotationZ`) |
| `MobileNetV2.mlmodel` | จำแนกรูปภาพกว่า 1,000 ประเภท ดาวน์โหลด `MobileNetV2FP16` จาก [Core ML Models](https://developer.apple.com/machine-learning/models/) แล้วเปลี่ยนชื่อไฟล์ |
| `EmotionClassifier.mlmodel` | Text classifier 6 อารมณ์ (joy, sadness, anger, fear, love, surprise) train ใน Create ML จาก Emotions dataset for NLP (Kaggle `praveengovi/emotions-dataset-for-nlp`) ด้วย Maximum Entropy |
| `YOLOv3Tiny.mlmodel` | หาวัตถุ 80 ประเภทพร้อมตำแหน่ง ดาวน์โหลด `YOLOv3TinyFP16` (16 MB) จากหน้าเดียวกัน แล้วเปลี่ยนชื่อไฟล์ ตัวเต็ม `YOLOv3FP16` ใหญ่ 118 MB เกินกว่าจะเก็บใน git |

ใช้ model ของทีมแทน: export จาก Create ML เป็นชื่อ `GestureClassifier.mlmodel` แล้วลากไปแทนไฟล์เดิม ถ้า train ด้วย 6 column เดิม ไม่ต้องแก้โค้ด ถ้าเปลี่ยน column ต้องแก้ `GestureClassifierInput(...)` ใน `Gesture.swift` ให้ตรงกับแท็บ Predictions ของ model

## `EmotionData/`: ข้อมูลสำรองสำหรับ train

ข้อมูลอารมณ์จากข้อความ (ภาษาอังกฤษ 6 อารมณ์) พร้อมใช้ใน Create ML Text Classifier ใช้เมื่อหาข้อมูลเองไม่ทัน ดูวิธีใช้ใน `EmotionData/README.md`

| ไฟล์ | จำนวน | ใช้ใน Create ML ช่อง |
|---|---|---|
| `emotion6_train.csv` | 18,000 ประโยค | Training Data |
| `emotion6_test.csv` | 2,000 ประโยค | Testing Data |
| `emotion6_mytest.csv` | 30 ประโยค | + New Test (ประโยคที่แต่งเอง) |

โฟลเดอร์นี้เห็นใน Project Navigator ของ Xcode แต่ไม่ได้อยู่ใน target ของ app จึงไม่ถูกใส่ไปใน app ตอน build

## Info.plist

| Key | ใช้กับ | Build setting ใน project นี้ |
|---|---|---|
| `NSMotionUsageDescription` | `CMAltimeter` (หน้านับชั้น) | `INFOPLIST_KEY_NSMotionUsageDescription` |
| `NSMicrophoneUsageDescription` | `SoundListener` | `INFOPLIST_KEY_NSMicrophoneUsageDescription` |
| `NSCameraUsageDescription` | `DepthReader` (LiDAR ทำงานผ่านกล้อง) | `INFOPLIST_KEY_NSCameraUsageDescription` |

`CMMotionManager` และ Core ML ไม่ต้องขอสิทธิ์ ถ้า copy ไฟล์ไปใช้ใน project อื่นแต่ไม่ใส่ key ที่ต้องใช้ app จะ crash

## ลองแก้เอง

- เปลี่ยน `2.0` ใน `detectGesture` ให้เขย่าเบาลงหรือแรงขึ้น
- เอียงหรือไม่เอียง: เปลี่ยน `1` องศาใน `isLevel` ให้เข้มงวดขึ้นหรือหลวมขึ้น
- เพิ่มเมนูของตัวเองใน `menus`
- แจ้งเตือนเสียงสำคัญ: เปิดหน้ารายชื่อเสียง หาเสียงที่อยากให้แจ้ง (เช่น `dog_bark`, `knock`) แล้วเพิ่มใน `important`
- ลดหรือเพิ่ม `0.7` แล้วดูว่าแจ้งเตือนผิดบ่อยขึ้นหรือพลาดบ่อยขึ้น
- เตือนสิ่งกีดขวาง: เปลี่ยนระยะ `0.5` และ `1.0` เมตร
- วันนี้รู้สึกอย่างไร: เปลี่ยน `minimumConfidence` (0.4) แล้วดูว่า 🤔 ขึ้นบ่อยขึ้นหรือน้อยลง และเปลี่ยน emoji หรือสีของแต่ละอารมณ์ใน `Mood`

## ตามไม่ทัน

ไฟล์ใน `SensorParts/` ทำงานครบทุกหัวข้อแล้ว copy ไปใส่ project ของทีมได้เลย ดูขั้นตอนใน handbook หน้า "ใส่ใน app ของทีม" ของ Workshop 3 ถ้าอัดข้อมูลหรือ train ไม่ทัน ใช้ `GestureClassifier.mlmodel` ในโฟลเดอร์นี้ไปก่อน

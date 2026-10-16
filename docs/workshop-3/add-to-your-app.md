# ใส่ใน app ของทีม

หน้านี้รวมสิ่งที่ต้องทำเพื่อย้าย feature จาก starter project ไปใส่ใน project ของทีม ทำตามลำดับ ใช้ได้ทั้ง Xcode 26 และ 27 ยกเว้น [Core AI](core-ai.md) ที่ต้องใช้ Xcode 27

## 0. ดาวน์โหลด starter project { #get-starter }

Starter project อยู่ในโฟลเดอร์ `starter/` ของ [repo handbook](https://github.com/tawapnas/yidh26-swift-handbook) นี้

| โฟลเดอร์ | ใช้ทำอะไร |
|---|---|
| [`workshop-3`](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-3) | app ตัวอย่าง แท็บละหัวข้อ: Motion, Sound, LiDAR, Core ML และโฟลเดอร์ `SensorParts/` ที่ copy ไปใช้ได้ |
| [`workshop-3/EmotionData`](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-3/EmotionData) | ข้อมูลสำหรับ train text classifier ใน [Create ML](create-ml.md) |

1. เปิด [repo handbook](https://github.com/tawapnas/yidh26-swift-handbook) กด **Code → Download ZIP** แล้วแตกไฟล์ (หรือใช้ `git clone` ก็ได้)
2. เปิด `starter/workshop-3/Workshop3Starter.xcodeproj`
3. เลือก target **Workshop3Starter** → **Signing & Capabilities** → เลือก **Team** ของตัวเอง แล้ว run บน iPad

## 1. เลือก feature { #pick-feature }

เลือก feature ที่ช่วยให้ app ของทีมรู้สิ่งที่เกิดขึ้นกับผู้ใช้

| ถ้า app ของทีมอยากรู้ว่า… | ใช้ | ตัวอย่าง |
|---|---|---|
| ผู้ใช้เขย่า เอียง หรือขยับเครื่อง | Core Motion | เขย่าเพื่อสุ่ม, เอียงเครื่องเล่นเกม |
| ผู้ใช้เดินขึ้นลงชั้น | Core Motion (barometer) | app ออกกำลังกาย, นำทางในอาคาร |
| ได้ยินเสียงอะไรรอบตัว | Sound Analysis | แจ้งเตือนเสียงกริ่งหรือเด็กร้องสำหรับคนที่ได้ยินไม่ชัด |
| สิ่งของอยู่ห่างกี่เมตร | LiDAR (iPad Pro เท่านั้น) | เตือนสิ่งกีดขวาง, วัดขนาดเฟอร์นิเจอร์ |
| ผู้ใช้รู้สึกอย่างไรจากข้อความที่พิมพ์ (ภาษาอังกฤษ) | Create ML + Core ML (text classifier) | บันทึกความรู้สึกประจำวัน, ตอบกลับให้เข้ากับอารมณ์ |
| ในรูปมีอะไร | Core ML + model สำเร็จรูปจาก Apple (MobileNetV2) | แยกประเภทอาหาร สัตว์ หรือสิ่งของ |
| ในรูปมีอะไรบ้าง กี่ชิ้น อยู่ตรงไหน | Core ML + YOLOv3 | นับคนในห้อง, หาของบนโต๊ะ, ตีกรอบสัตว์เลี้ยง |

## 2. Copy ไฟล์ { #files }

ไฟล์ทั้งหมดอยู่ในโฟลเดอร์ `SensorParts/` ของ starter project (ไฟล์ model อยู่ใน `SensorParts/Models/`) ลากเข้า Xcode project แล้วติ๊ก **Copy items if needed** และเลือก target ของ app

| Feature | ไฟล์ที่ต้อง copy |
|---|---|
| การเคลื่อนไหว, มุมเอียง, ท่าแบบง่าย, barometer | `Motion.swift` |
| จดจำเสียง | `Sound.swift` |
| วัดระยะด้วย LiDAR | `Lidar.swift` |
| อารมณ์จากข้อความ | `TextEmotion.swift`, `EmotionClassifier.mlmodel` (หรือ model ของทีม) |
| บอกว่าในรูปมีอะไร | `ImageClassifier.swift`, `MobileNetV2.mlmodel` |
| หาวัตถุในรูปพร้อมตำแหน่ง | `ObjectDetector.swift`, `YOLOv3Tiny.mlmodel` |

ไฟล์แต่ละชุดไม่ขึ้นต่อกัน จึง copy เฉพาะชุดที่ต้องใช้ได้ ทุกไฟล์ build ผ่านใน project ที่ตั้ง **Swift Language Version เป็น Swift 5** ซึ่งเป็นค่าเริ่มต้นของ project ใหม่ใน Xcode 26

หน้าจอใน `Tabs/` ของ starter เป็นตัวอย่างการเรียกใช้ จะ copy มาแก้ต่อก็ได้ หรือดูแล้วเขียนหน้าจอของทีมเอง

## 3. Model { #models }

ข้ามขั้นนี้ได้ถ้าไม่ได้ใช้ Core ML

1. ลากไฟล์ `.mlmodel` เข้า project แล้วติ๊ก target ของ app Xcode จะสร้าง class ชื่อเดียวกับไฟล์ให้
2. ถ้าใช้ `TextEmotion.swift` ตั้งชื่อไฟล์ model ว่า `EmotionClassifier.mlmodel` ถ้าตั้งชื่ออื่น ต้องแก้ชื่อ class ใน `TextEmotion.swift` ให้ตรง
3. ถ้า train อารมณ์อื่นนอกจาก 6 อารมณ์เดิม ให้เพิ่ม emoji และสีของอารมณ์นั้นในหน้าจอของทีม (ใน starter อยู่ใน `Mood` ของ `MoodView.swift`)

Model ที่ train ตาม[หน้า Create ML](create-ml.md) ด้วยไฟล์ที่มี column `text` และ `label` ใช้กับ `TextEmotion.swift` ได้โดยไม่ต้องแก้

## 4. Info.plist { #info-plist }

ใน Xcode เลือก target → แท็บ **Info** → กด + แล้วเพิ่ม key ต่อไปนี้ตาม feature ที่ใช้

| Key | ต้องใช้เมื่อ | ตัวอย่างข้อความ |
|---|---|---|
| `Privacy - Motion Usage Description` (`NSMotionUsageDescription`) | ใช้ barometer (`startAltitudeUpdates`) | "ใช้ข้อมูลการเคลื่อนไหวเพื่อนับการขึ้นลงชั้น" |
| `Privacy - Microphone Usage Description` (`NSMicrophoneUsageDescription`) | ใช้ `SoundListener` | "ฟังเสียงรอบตัวเพื่อแจ้งเตือนเมื่อได้ยินเสียงสำคัญ" |
| `Privacy - Camera Usage Description` (`NSCameraUsageDescription`) | ใช้ `DepthReader` (LiDAR ทำงานผ่านกล้อง) | "ใช้กล้องและ LiDAR เพื่อวัดระยะห่างของสิ่งของ" |

`startMotionUpdates` (accelerometer, gyroscope) และ Core ML ไม่ต้องเพิ่ม key ใดๆ ผู้ใช้จะเห็นข้อความนี้ตอนที่ app ขอสิทธิ์ จึงควรเขียนให้ชัดว่าใช้ทำอะไร

## 5. เช็กเครื่องและสิทธิ์ก่อนใช้ { #checks }

- **LiDAR**: เช็ก `hasLiDAR` ก่อนแสดง feature วัดระยะ ถ้าเป็น `false` ให้แสดงข้อความว่าเครื่องนี้ไม่รองรับ หรือซ่อน feature นั้น
- **การเคลื่อนไหว**: `startMotionUpdates` เช็ก `isDeviceMotionAvailable` ให้แล้ว แต่ถ้าเป็น `false` จะไม่มีอะไรเกิดขึ้นเลย ควรแสดงข้อความบอกผู้ใช้
- **ไมโครโฟน**: ถ้า `AVAudioApplication.requestRecordPermission()` ได้ `false` ให้แสดงข้อความแนะนำให้ไปเปิดสิทธิ์ใน Settings
- **หยุดเมื่อออกจากหน้าจอ**: เรียก `stop…` ใน `onDisappear` ทุกครั้ง sensor ไมโครโฟน และกล้องที่เปิดค้างกินแบตเตอรี่
- **ทดสอบบนเครื่องไหน**:

| Feature | Simulator | iPad จริง |
|---|---|---|
| Core Motion | ไม่ได้ (ไม่มี sensor) | ได้ |
| Sound | ได้ (ใช้ไมโครโฟนของ Mac) | ได้ |
| LiDAR | ไม่ได้ | เฉพาะ iPad Pro |
| อารมณ์จากข้อความ | ได้ | ได้ |
| บอกว่าในรูปมีอะไร, หาวัตถุในรูป | ได้ (ลากรูปไปวางบน Simulator) | ได้ |

## 6. ให้ agent ช่วย { #agent-prompts }

ใช้ template จาก [Workshop 1](../workshop-1/prompting.md) แล้วระบุไฟล์ที่ copy มาให้ชัด agent จะได้ใช้ฟังก์ชันที่มีอยู่แล้ว ไม่เขียน `CMMotionManager` หรือ `AVAudioEngine` ขึ้นมาใหม่

```text
Context: SwiftUI app, iOS 26, Swift 5 มี TextEmotion.swift (class EmotionDetector
ที่คืนความมั่นใจของ 6 อารมณ์: joy, sadness, anger, fear, love, surprise) และ
EmotionClassifier.mlmodel อยู่แล้ว
Task: ใน JournalView เมื่อผู้ใช้กดบันทึก ให้เก็บอารมณ์ที่มั่นใจที่สุดคู่กับข้อความ
ถ้ามั่นใจไม่ถึง 0.4 ให้เก็บเป็น "unsure" แล้วแสดง emoji ของอารมณ์ในรายการบันทึก
Constraints: ห้ามแก้ TextEmotion.swift, สร้าง EmotionDetector ครั้งเดียวแล้วใช้ซ้ำ,
ข้อความเป็นภาษาอังกฤษ
Done when: build ผ่าน และพิมพ์ "today was a really good day" แล้วบันทึกได้ 😄
```

เปลี่ยน `JournalView` เป็นหน้าจอของทีม ถ้า train อารมณ์อื่นเอง ให้ใส่ชื่ออารมณ์ใน Context ด้วย agent จะได้รู้ว่า model ตอบอะไรได้บ้าง

```text
Context: มี Sound.swift (class SoundListener ที่ใช้ classifier ในตัวของ
Sound Analysis) อยู่แล้ว และตั้ง NSMicrophoneUsageDescription แล้ว
Task: เพิ่ม banner สีแดงด้านบนของ HomeView เมื่อได้ยิน "door_bell" หรือ
"knock" ด้วยความมั่นใจเกิน 0.7 แล้วซ่อนเองหลัง 3 วินาที
Constraints: ห้ามแก้ Sound.swift, ขอสิทธิ์ไมโครโฟนก่อนเรียก start(),
หยุดฟังใน onDisappear
Done when: build ผ่าน และเปิดเสียงกริ่งให้ iPad ฟังแล้วขึ้น banner
```

```text
Context: มี Lidar.swift (hasLiDAR และ class DepthReader) อยู่แล้ว
Task: เพิ่มปุ่ม "วัดระยะ" ใน SettingsView ที่เปิดหน้าแสดงระยะเป็นเมตร
โดยแสดงปุ่มนี้เฉพาะเครื่องที่ hasLiDAR เป็น true
Constraints: ห้ามแก้ Lidar.swift, อัปเดตจอไม่เกิน 5 ครั้งต่อวินาที
Done when: build ผ่าน, iPad Pro เห็นปุ่มและวัดระยะได้, iPad รุ่นอื่นไม่เห็นปุ่ม
```

## ปัญหาที่เจอบ่อย { #troubleshooting }

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| `property 'userAcceleration' is not available due to missing import of defining module 'CoreMotion'` | ไฟล์หน้าจอใช้ค่าจาก `CMDeviceMotion` แต่ไม่ได้ import CoreMotion | เพิ่ม `import CoreMotion` บนสุดของไฟล์นั้น |
| `Cannot find 'startMotionUpdates' in scope` | ไฟล์ไม่ได้อยู่ใน target ของ app | เลือกไฟล์ → File inspector → ติ๊ก target ใน **Target Membership** |
| `Cannot find 'EmotionClassifier' in scope` | ไม่มีไฟล์ model ใน target หรือชื่อไฟล์ไม่ตรง | ดู [Model](#models) |
| `Multiple commands produce '…/EmotionClassifier.mlmodelc'` | มีไฟล์ model ชื่อเดียวกัน 2 ไฟล์ใน project | ลบไฟล์เก่าออกให้เหลือไฟล์เดียว |
| `let 'motion' is not concurrency-safe` | Project ของทีมตั้งเป็น Swift 6 | target → **Build Settings** → ค้น `Swift Language Version` แล้วเลือก **Swift 5** |
| Crash ตอนเปิดหน้าเสียง หน้านับชั้น หรือหน้า LiDAR (ใน starter ไม่ crash) | Starter มี Info.plist key แต่ project ของทีมไม่มี | ดู [Info.plist](#info-plist) |
| ตัวเลขไม่ขยับเลย | Run บน Simulator ซึ่งไม่มี sensor การเคลื่อนไหว | Run บน iPad จริง |
| อารมณ์ที่ทายได้ไม่ตรงกับข้อความ หรือทายเป็นอารมณ์เดิมตลอด | พิมพ์ภาษาไทย หรือประโยคต่างจากข้อมูลที่ใช้ train มาก | พิมพ์เป็นภาษาอังกฤษ ใช้[ความมั่นใจตัดสิน](core-ml.md#confidence) และเพิ่มประโยคแบบที่ผู้ใช้พิมพ์ลงในข้อมูลแล้ว train ใหม่ ดู[ทำให้ model ดีขึ้น](create-ml.md) |
| Create ML ขึ้น `missing required field label` | ไฟล์ CSV ไม่มี column ชื่อ `label` | เปลี่ยนชื่อ column ให้เป็น `text` และ `label` ดู[รูปแบบไฟล์](create-ml.md#data) |
| หน้า LiDAR ขึ้นว่าไม่มี LiDAR | iPad รุ่นนี้ไม่มี LiDAR | ใช้ iPad Pro หรือเลือก feature อื่น |
| Agent เขียน `CMMotionManager` หรือ `AVAudioEngine` ใหม่ทั้งหมด | Agent ไม่รู้ว่ามีไฟล์อยู่แล้ว | บอกใน prompt ว่ามีไฟล์ไหน และห้ามแก้ ดู[ตัวอย่าง prompt](#agent-prompts) |

!!! danger "เสียงและการเคลื่อนไหวเป็นข้อมูลส่วนบุคคล"
    Sound Analysis, Core Motion และ Core ML ประมวลผลบน iPad ไม่ส่งข้อมูลออกนอกเครื่อง แต่ถ้า app บันทึกเสียง เก็บข้อมูลการเคลื่อนไหว หรือส่งผลไปที่ cluster หรือ server ต้องแจ้งให้ผู้ใช้ทราบ

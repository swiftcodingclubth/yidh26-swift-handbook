# Workshop 3 starter: Core Motion

Starter project ของ Workshop 3 · iOS 26 · ไม่มี dependency ภายนอก · เปิดได้ทั้ง Xcode 26 และ 27

ใช้เฉพาะโค้ดจากหน้า **Core Motion** ใน handbook ไม่มีอะไรเพิ่ม ทุกหน้าจอทำแบบเดียวกับ `MotionView`: เริ่มรับข้อมูลใน `onAppear` และหยุดใน `onDisappear`

## เริ่มใช้งาน

1. เปิด `Workshop3Starter.xcodeproj`
2. เลือก target **Workshop3Starter** → **Signing & Capabilities** → เลือก **Team** ของตัวเอง
3. เลือก iPad เป็น run destination แล้วกด Run

Simulator ไม่มี sensor การเคลื่อนไหว ต้อง run บน iPad จริง

## ไฟล์

| ไฟล์ | มีอะไร |
|---|---|
| `Motion.swift` | โค้ดจาก handbook: `startMotionUpdates`, `stopMotionUpdates`, `detectGesture`, `startAltitudeUpdates` |
| `UseCases/MotionView.swift` | ตัวอย่าง `MotionView` จาก handbook ขยายเป็น 3 แกน พร้อมแถบแสดงแรง |
| `UseCases/AttitudeView.swift` | ตัวอย่าง `AttitudeView` จาก handbook: มุม pitch, roll, yaw |
| `UseCases/LevelView.swift` | Use case: ที่วัดระดับน้ำ |
| `UseCases/ShakeMenuView.swift` | Use case: เขย่าสุ่มเมนูมื้อเที่ยง |
| `UseCases/StairsView.swift` | Use case: นับชั้นที่เดินขึ้นบันได |

## Use case

| Use case | ลองทำ | ใช้ค่าอะไร | หัวข้อใน handbook |
|---|---|---|---|
| **MotionView** | เหวี่ยง iPad ซ้าย-ขวา ขึ้น-ลง เข้า-ออก ดูแถบแต่ละแกนขยับ | `userAcceleration.x`, `.y`, `.z` | อ่านข้อมูลการเคลื่อนไหว |
| **AttitudeView** | วาง iPad ราบ แล้วพยักหน้า เอียงคอ ส่ายหน้า | `attitude.pitch`, `.roll`, `.yaw` | มุมของเครื่อง: roll, pitch, yaw |
| **เอียงหรือไม่เอียง?** | วาง iPad ราบบนโต๊ะ เส้นเขียว = โต๊ะไม่เอียง | `attitude.roll` | มุมของเครื่อง: roll, pitch, yaw |
| **เขย่าสุ่มเมนู** | เขย่าแรงๆ ได้เมนูมื้อเที่ยงแบบสุ่ม | `detectGesture` | ตรวจจับท่าแบบง่ายโดยไม่ใช้ ML |
| **นับชั้น** | ถือ iPad เดินขึ้นหรือลงบันได | `CMAltimeter` | Barometer |

## ลองแก้เอง

- เปลี่ยน `2.0` ใน `detectGesture` ให้เขย่าเบาลงหรือแรงขึ้น
- ที่วัดระดับน้ำ: เปลี่ยน `1` องศาใน `isLevel` ให้เข้มงวดขึ้นหรือหลวมขึ้น
- เพิ่มเมนูของตัวเองใน `menus`

## Permission

หน้านับชั้นใช้ `CMAltimeter` จึงต้องมี `NSMotionUsageDescription` ใน Info.plist project นี้ตั้งไว้แล้วใน build setting `INFOPLIST_KEY_NSMotionUsageDescription` ถ้าไม่ใส่ app จะ crash

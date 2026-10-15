# Widget และ Control Center

**Interactive widget** คือ widget ที่มีปุ่มกดได้บน Home Screen และ **Control** คือปุ่มที่ผู้ใช้เพิ่มเองใน Control Center หรือ Lock Screen ทั้งสองแบบใช้ App Intent เป็น action ของปุ่ม เราจึงใช้ `LogWaterIntent` ตัวเดิมได้เลยโดยไม่ต้องเขียน action ใหม่ ใช้ได้ทั้ง Xcode 26 และ 27

!!! note "หัวข้อนี้ไม่บังคับ"
    ใน workshop ผู้บรรยายจะ demo ปุ่มใน widget และ Control Center จาก `Finished` ให้ดู ไม่ต้องทำตามระหว่าง session ถ้าสนใจ ทำตามหน้านี้ได้ทีหลัง ทุกขั้นเป็นการ paste เหมือนหน้าอื่น

ใช้ทำอะไรได้: กดบันทึกจาก Home Screen, ปุ่มเริ่ม/หยุดจับเวลาใน Control Center, เช็กอินหรือ mark ว่าทำเสร็จแล้วโดยไม่ต้องเปิด app

## Setup { #setup }

Starter project มี **Widget Extension** (`WaterLogWidgets`) และ **App Group** ตั้งไว้ให้แล้ว ถ้าทำใน app ของทีม ดูวิธีเพิ่มเองได้ที่ [App Group](add-to-your-app.md#app-group)

ต้องมี App Group เพราะ widget และ control ทำงานใน process ของ widget extension ซึ่งแยกจาก app เมื่อกดปุ่มใน widget `perform()` จึงทำงานใน extension และต้องเขียนข้อมูลลงที่ที่ app อ่านได้ด้วย ใน starter คือ `UserDefaults(suiteName:)` ของ App Group ใน `Shared/WaterStore.swift`

| Process | Intent ที่ run ที่นี่ | อ่าน/เขียนข้อมูลที่ |
|---|---|---|
| `WaterLog` (app) | ปุ่มใน app, Siri, Shortcuts, Spotlight | App Group |
| `WaterLogWidgets` (extension) | ปุ่มใน widget และ Control Center | App Group เดียวกัน |

## 1. ใส่ปุ่มใน widget { #widget-button }

ใน `WaterLogWidgets/WaterWidget.swift` แทนบรรทัด `TODO Code-along 2` ด้วยโค้ดนี้

```swift
            // ปุ่มนี้ run LogWaterIntent ได้เลย โดยไม่ต้องเปิด app
            Button(intent: LogWaterIntent(milliliters: 250)) {
                Label("250 ml", systemImage: "plus")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
            }
            .tint(.blue)
```

ปุ่มใน widget ใช้ได้แค่ `Button(intent:)` และ `Toggle(isOn:intent:)` เท่านั้น ปุ่มแบบ closure ธรรมดาจะไม่ทำงาน เพราะ widget ไม่ได้ run โค้ดของ view ตอนที่ผู้ใช้กด ระบบแค่ส่ง intent ไป run ให้

เมื่อ `perform()` ทำงานเสร็จ ระบบจะ reload widget ให้เอง ส่วนเมื่อบันทึกจาก app หรือ Siri `WaterStore` จะเรียก `WidgetCenter.shared.reloadAllTimelines()` เพื่อให้ widget แสดงยอดล่าสุด

## 2. ใส่ปุ่มใน Control Center { #control }

สร้างไฟล์ `WaterLogWidgets/LogWaterControl.swift` แล้ว paste โค้ดนี้ทั้งหมด

```swift
--8<-- "starter/workshop-4/Finished/WaterLogWidgets/LogWaterControl.swift"
```

จากนั้นใน `WaterLogWidgetsBundle.swift` แทนบรรทัด `TODO Code-along 2` ด้วย

```swift
        LogWaterControl()
```

โค้ดนี้ทำอะไร: `ControlWidgetButton(action:)` รับ `LogWaterIntent` ตัวเดิม ส่วน `displayName` คือชื่อที่ผู้ใช้เห็นตอนเลือก control ใน Control Center

`kind` ต้องไม่ซ้ำกับ widget หรือ control อื่นใน app ถ้าต้องการปุ่มเปิด/ปิด เช่น เริ่ม/หยุดจับเวลา ให้ใช้ `ControlWidgetToggle` คู่กับ intent ที่ conform `SetValueIntent`

## 3. เพิ่มบน iPad { #add-on-ipad }

Run app บน iPad ก่อน 1 ครั้ง แล้วเพิ่มด้วยมือ

| อะไร | ทำอย่างไร |
|---|---|
| Widget | กดค้างที่ Home Screen → **Edit** → **Add Widget** → ค้นหา "My Drink" |
| Control | ปัดลงจากมุมขวาบนเพื่อเปิด Control Center → กดค้างที่ที่ว่าง → **Add a Control** → ค้นหา "My Drink" |

กดปุ่มใน widget แล้วเปิด app ยอดใน app ต้องตรงกับใน widget

!!! note "iPad ไม่มี Action button"
    บน iPhone ผู้ใช้ตั้ง Action button ให้ run control หรือ App Shortcut ได้ด้วย แต่ iPad ของงานไม่มีปุ่มนี้ ให้ demo ผ่าน Control Center แทน

## ปัญหาที่เจอบ่อย { #troubleshooting }

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| กดปุ่มใน widget แล้ว app ไม่เห็นข้อมูลใหม่ | App และ extension ไม่ได้ใช้ App Group เดียวกัน | เช็กว่าทั้ง 2 target มี App Group เดียวกันใน **Signing & Capabilities** |
| App ไม่อัปเดตหลังกดปุ่มใน widget | App ยังแสดงข้อมูลชุดเก่าอยู่ในหน่วยความจำ | อ่านข้อมูลใหม่เมื่อ app กลับมาเปิด (`scenePhase == .active`) แบบใน `ContentView.swift` |
| ไม่เจอ My Drink ในรายการ widget หรือ control | ยังไม่เคย run app ที่มี extension บน iPad หรือ extension build ไม่ผ่าน | Run scheme `WaterLog` (ไม่ใช่ `WaterLogWidgets`) แล้วรอสักครู่ |
| `Cannot find 'LogWaterIntent' in scope` ใน widget | ไฟล์ intent อยู่ใน target ของ app อย่างเดียว | ย้ายไฟล์ไปไว้ใน `IntentParts/` หรือติ๊ก `WaterLogWidgets` ใน **Target Membership** |
| Widget แสดง placeholder ตลอด | `getTimeline` ไม่เรียก `completion` | เรียก `completion` ทุกทาง แม้อ่านข้อมูลไม่ได้ |

## ใช้ร่วมกับ

- [Intent แรก](first-intent.md): intent ที่ใช้ในปุ่มทั้งสองแบบ
- [App entities](app-entities.md): ถ้าอยากให้ผู้ใช้เลือกได้ว่า widget แสดงอะไร ให้ใช้ `AppIntentConfiguration` กับ entity

## ไปต่อ { #next }

- **Live Activity**: แสดงสถานะที่กำลังทำอยู่บน Lock Screen แล้วใช้ `LiveActivityIntent` ทำปุ่มใน Live Activity ดู [Live Activities essentials (WWDC26)](https://developer.apple.com/videos/play/wwdc2026/223/) iPad ของงานแสดงปุ่มใน Live Activity ไม่ได้
- **Widget ที่ผู้ใช้ตั้งค่าได้**: `AppIntentConfiguration` + `WidgetConfigurationIntent`

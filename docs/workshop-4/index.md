# Extend your app across the system with App Intents

Workshop นี้ทำให้ action ของ app ทีมออกไปอยู่นอก app: เขียน action ครั้งเดียว แล้วใช้ได้ทั้งใน Shortcuts, Spotlight, Siri, widget และ Control Center โดยไม่ต้องเปิด app และยังเป็นช่องทางที่ Siri AI กับ action "Use Model" ใน Shortcuts ใช้เข้าถึงข้อมูลและ action ของ app เรา

ต่อจาก [Workshop 2](../workshop-2/index.md): ใน Tool calling model **ของเรา** เรียกโค้ดของเรา ส่วน App Intents คือช่องทางที่ model **ของระบบ** เรียกโค้ดของเรา

## สิ่งที่จะได้เรียน { #outcomes }

1. **เขียน App Intent แรก**: ทำ action "Log Water" ที่ run ได้จาก Shortcuts, Spotlight และ Siri ด้วย App Shortcuts ทันทีที่ติดตั้ง app
2. **ใช้ intent ตัวเดิมในปุ่มของระบบ**: ดูว่า intent ตัวเดิมกลายเป็นปุ่มใน widget และ Control Center ได้อย่างไร โดยไม่ต้องเขียน action ใหม่ (ผู้บรรยาย demo ทำตามเองได้ถ้าสนใจ)
3. **ให้ระบบรู้จักข้อมูลของ app**: ทำ `AppEntity` และ `EntityQuery` แล้วส่งข้อมูลเข้า Spotlight เพื่อให้ Siri และ "Use Model" อ่านข้อมูลนั้นได้
4. **เข้าใจว่า Siri AI ทำอะไรได้**: Siri ที่คุยด้วยภาษาธรรมดาได้ใช้ข้อมูลและ action ของ app อย่างไร และ app ของทีมเข้ากับ App Schema domain ไหน

## แนวคิดหลัก { #concepts }

### คำนาม คำกริยา และวลี

| ส่วน | เปรียบได้กับ | ใน My Drink | หน้าที่ |
|---|---|---|---|
| **`AppIntent`** | คำกริยา | `LogWaterIntent` | action หนึ่งอย่างที่ app ทำได้ |
| **`AppEntity`** | คำนาม | `DrinkEntity` | ข้อมูลใน app ที่ระบบควรรู้จัก |
| **`AppEnum`** | ตัวเลือก | `Beverage` (น้ำ ชา กาแฟ…) | ค่าที่มีจำนวนจำกัด |
| **`AppShortcut`** | วลี | "Log water in My Drink" | ประโยคที่ทำให้ intent ใช้ได้ทันที |

### เขียนครั้งเดียว ใช้ได้ทุกที่

```swift
struct LogWaterIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Water"
    @Parameter(title: "Amount (ml)", default: 250) var milliliters: Int

    @MainActor
    func perform() async throws -> some IntentResult {
        WaterStore.shared.add(milliliters: milliliters)   // เรียกโค้ดเดิมของ app
        return .result()
    }
}
```

| ถ้าต้องการให้ intent ไปอยู่ที่… | ใช้ | ดู |
|---|---|---|
| Shortcuts app | แค่เขียน `AppIntent` | [Intent แรก](first-intent.md#shortcuts) |
| Spotlight และ Siri ทันทีที่ติดตั้ง app | `AppShortcutsProvider` | [Intent แรก](first-intent.md#app-shortcuts) |
| ปุ่มใน app, widget | `Button(intent:)` | [Widget และ Control Center](widgets-controls.md#widget-button) |
| Control Center, Lock Screen | `ControlWidgetButton(action:)` | [Widget และ Control Center](widgets-controls.md#control) |
| ผลค้นหาใน Spotlight, "Use Model" | `AppEntity` + `IndexedEntity` | [App entities](app-entities.md) |
| Siri AI | App Schema + onscreen awareness | [Siri AI](siri-ai.md) |

`perform()` ควรเรียกโค้ดเดิมของ app เช่น `WaterStore` เพื่อให้มี logic อยู่ที่เดียว ทุก surface จึงได้ผลเหมือนกันเสมอ

## MacBook แต่ละเครื่องทำอะไรได้บ้าง { #machines }

App Intents, widget และ Control Center มีตั้งแต่ Xcode 26 ส่วนที่ต้องใช้ Xcode 27 มีแค่หน้า [Siri AI](siri-ai.md)

!!! mchip "{{ mac.apple }} · Xcode 27"
    ทำได้ครบทุกส่วน รวมถึง App Schema (`@AppIntent(schema:)`) และทดสอบ intent ด้วย AppIntentsTesting ซึ่งเป็น API ของ iOS 27

!!! intel "{{ mac.intel }} · Xcode 26"
    ทำได้ทุกหัวข้อยกเว้น [Siri AI](siri-ai.md) โค้ดใน starter project ครอบส่วนที่เป็น iOS 27 ไว้แล้ว จึงเปิดและ build ได้ทั้งสองเครื่อง

    iPad ของงานเป็น iPadOS 27 Siri และ "Use Model" ใน Shortcuts จึงเรียก intent ของ app ที่ build จาก Xcode 26 ได้เช่นกัน ที่ทำไม่ได้มีแค่การใช้ App Schema และ AppIntentsTesting

## หัวข้อหลัก { #pages }

อ่านตามลำดับนี้จะเข้าใจง่ายที่สุด

| หน้า | เนื้อหา |
|---|---|
| [Intent แรก](first-intent.md) | `AppIntent`, parameter, ลองใน Shortcuts, App Shortcuts สำหรับ Spotlight และ Siri |
| [Widget และ Control Center](widgets-controls.md) | ใช้ intent ตัวเดิมในปุ่มของ widget และ Control Center, App Group |
| [App entities](app-entities.md) | `AppEnum`, `AppEntity`, `EntityQuery`, ส่งข้อมูลเข้า Spotlight และ "Use Model" |
| [Siri AI](siri-ai.md) | App Schema, onscreen awareness และ AppIntentsTesting |
| [ใส่ใน app ของทีม](add-to-your-app.md) | Checklist ทุก surface, ไฟล์ที่ copy ได้ และ prompt สำหรับ agent |

## ลงมือปฏิบัติ { #hands-on }

Starter project อยู่ในโฟลเดอร์ [`starter/workshop-4`](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-4) ของ repo handbook นี้ มี 2 แบบ: `Start` ใช้ทำ code-along และ `Finished` ที่ทำเสร็จแล้ว ดูวิธีเปิดใน[ใส่ใน app ของทีม](add-to-your-app.md#get-starter)

### 1. ทำตามไปด้วยกัน: My Drink

เพิ่ม action "Log Water" ให้ app บันทึกการดื่มน้ำ แล้วกดได้จากทุก surface ของระบบ ทุกขั้นเป็นการ copy โค้ดจากหน้า handbook ไป paste (กดปุ่ม copy ที่มุมขวาบนของ code block) แล้วอ่านว่าโค้ดแต่ละส่วนทำอะไร ไม่ต้องพิมพ์เอง

1. **Paste `LogWaterIntent`** แล้ว run จาก Shortcuts ดู [Intent แรก](first-intent.md#first-intent)
2. **เพิ่ม App Shortcut** แล้วค้นหาใน Spotlight และพิมพ์สั่ง Siri ดู [App Shortcuts](first-intent.md#app-shortcuts)
3. **ดู demo ปุ่มใน widget และ Control Center** ที่ใช้ intent ตัวเดิม (ไม่บังคับทำตาม) ดู [Widget และ Control Center](widgets-controls.md)
4. **ทำ `DrinkEntity`** แล้วส่งเข้า Spotlight ดู [App entities](app-entities.md#entity)
5. **ส่งข้อมูลให้ "Use Model"** ใน Shortcuts ช่วยสรุปว่าวันนี้ดื่มน้ำพอหรือยัง ดู [Use Model](app-entities.md#use-model)

### 2. ใส่ใน app ของทีม

เลือก 1 action ที่ผู้ใช้ทำบ่อยที่สุดใน app ของทีม แล้วทำให้ใช้ได้จากนอก app อย่างน้อย 3 surface

1. **เลือก action** ที่ทำเสร็จได้ในขั้นเดียว เช่น บันทึก เริ่ม/หยุด หรือเปิดหน้าหนึ่ง ดู [เลือก action](add-to-your-app.md#pick-action)
2. **ให้ agent เขียน intent** ด้วย prompt ที่เตรียมไว้ ดู [Prompt สำหรับ agent](add-to-your-app.md#agent-prompts)
3. **ทดสอบทีละ surface** ตาม checklist ดู [Checklist](add-to-your-app.md#checklist)
4. **ดูว่า app ของทีมอยู่ domain ไหน** ของ Siri AI ถ้ามี {{ mac.apple }} ให้ลองใส่ App Schema ดู [Siri AI](siri-ai.md#schema)

!!! tip "ตามไม่ทัน"
    เปิด `starter/workshop-4/Finished` ซึ่งทำครบทุกขั้นแล้ว หรือ copy ไฟล์ทั้งหมดใน `Finished/IntentParts/` กับ `Finished/WaterLog/WaterShortcuts.swift` ไปใส่ใน `Start` แล้วเอา comment ออกจากบรรทัด `TODO Code-along 3` ใน `WaterStore.swift`

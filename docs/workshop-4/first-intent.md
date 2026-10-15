# Intent แรก

**App Intent** คือ struct ที่บอกระบบว่า app ทำอะไรได้หนึ่งอย่าง มีชื่อ, ข้อมูลที่ต้องใช้ (parameter) และโค้ดที่ทำงานจริงใน `perform()` เมื่อเขียนแล้ว Xcode จะดึงข้อมูลของ intent ไปให้ระบบตอน build จึงไม่ต้องลงทะเบียนเอง ใช้ได้ทั้ง Xcode 26 และ 27

ใช้ทำอะไรได้: บันทึกการดื่มน้ำหรือยาโดยไม่ต้องเปิด app, เริ่มจับเวลาอ่านหนังสือจาก Siri, เปิดหน้าสรุปของวันนี้จาก Spotlight, ให้ผู้ใช้ต่อ action ของเรากับ app อื่นใน Shortcuts

## Setup

1. เปิด `starter/workshop-4/Start/WaterLog.xcodeproj` (ดู[ดาวน์โหลด starter](add-to-your-app.md#get-starter))
2. เลือก **Team** ใน **Signing & Capabilities** ของทั้ง 2 target: `WaterLog` และ `WaterLogWidgets`
3. Run บน iPad แล้วกดปุ่ม **Water 250 ml** ดูว่าวงแหวนของวันนี้เพิ่มขึ้น

ไฟล์ใหม่ที่เป็น intent ให้สร้างในโฟลเดอร์ `IntentParts/` เพราะโฟลเดอร์นี้อยู่ในทั้ง app และ widget extension

!!! tip "ไม่ต้องพิมพ์โค้ดเอง"
    ทุก code block ในหน้านี้กดปุ่ม copy ที่มุมขวาบนแล้ว paste ได้เลย ให้ใช้เวลาอ่านว่าโค้ดแต่ละส่วนทำอะไรแทนการพิมพ์ วิธีสร้างไฟล์ใหม่: คลิกขวาที่โฟลเดอร์ใน Xcode → **New File from Template…** → **Swift File** → ตั้งชื่อ แล้วลบโค้ดที่ Xcode ใส่มาให้ก่อน paste

## 1. เขียน intent แรก { #first-intent }

สร้างไฟล์ `IntentParts/LogWaterIntent.swift` แล้ว paste โค้ดนี้ทั้งหมด

```swift
import AppIntents

struct LogWaterIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Water"
    static let description = IntentDescription("Record a drink in My Drink.")

    @Parameter(title: "Amount (ml)", default: 250, inclusiveRange: (50, 1000))
    var milliliters: Int

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        WaterStore.shared.add(milliliters: milliliters)
        let total = WaterStore.shared.todayTotal
        return .result(dialog: "Logged \(milliliters) ml. Today: \(total) ml.")
    }
}

extension LogWaterIntent {
    init(milliliters: Int) {
        self.milliliters = milliliters
    }
}
```

โค้ดนี้ทำอะไร: intent ไม่ได้บันทึกข้อมูลเอง แต่เรียก `WaterStore` ซึ่งเป็นโค้ดเดิมของ app แบบเดียวกับปุ่มใน app

- `title` คือชื่อที่ผู้ใช้เห็นใน Shortcuts และ Spotlight
- `@Parameter` คือข้อมูลที่ระบบจะถามผู้ใช้ หรือให้ผู้ใช้ตั้งค่าไว้ใน Shortcuts
- `ProvidesDialog` ทำให้ Siri พูดหรือแสดงข้อความหลังทำเสร็จ
- `@MainActor` ที่ `perform()` จำเป็นเพราะ `WaterStore` ทำงานบน main actor ถ้าไม่ใส่จะ build ไม่ผ่าน
- `init(milliliters:)` ใช้ตอนสร้าง intent เองในโค้ด เช่น ปุ่มใน app และใน widget

## 2. ลองใน Shortcuts { #shortcuts }

Run app บน iPad อีกครั้ง แล้วเปิด app **Shortcuts** → **+** → ค้นหา "My Drink" จะเห็น action **Log Water** เพิ่ม action แล้วกด ▶︎ ยอดใน app จะเพิ่มขึ้น

เราไม่ได้เขียนโค้ดสำหรับ Shortcuts เลย แค่มี struct ที่ conform `AppIntent` ระบบก็นำไปแสดงเอง

## 3. เพิ่ม App Shortcut { #app-shortcuts }

ถ้ามีแค่ intent ผู้ใช้ต้องสร้าง shortcut เองก่อน แต่ **App Shortcut** ทำให้ intent ใช้ได้ทันทีที่ติดตั้ง app ทั้งใน Spotlight, Siri และหน้า Shortcuts สร้างไฟล์ `WaterLog/WaterShortcuts.swift` (ในโฟลเดอร์ของ app ไม่ใช่ `IntentParts/`) แล้ว paste โค้ดนี้ทั้งหมด ในหน้าต่างสร้างไฟล์ ให้ติ๊ก target `WaterLog` อย่างเดียว (Xcode มักติ๊ก `WaterLogWidgets` ไว้ให้จากไฟล์ก่อนหน้า)

```swift
import AppIntents

struct WaterShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogWaterIntent(),
            phrases: ["Log water in \(.applicationName)"],
            shortTitle: "Log Water",
            systemImageName: "drop.fill"
        )
    }
}
```

ทุก phrase ต้องมี `\(.applicationName)` เพื่อให้ Siri รู้ว่าหมายถึง app ไหน App หนึ่งมี `AppShortcutsProvider` ได้ตัวเดียว และมี App Shortcut ได้สูงสุด 10 ตัว ดูตัวอย่างที่มีหลาย phrase และหลาย intent ได้ใน `Finished/WaterLog/WaterShortcuts.swift`

## 4. ลองใน Spotlight และ Siri { #spotlight-siri }

Run app อีกครั้ง แล้วลองทั้ง 3 ที่

| ที่ | ทำอย่างไร | ควรเห็น |
|---|---|---|
| Spotlight | ปัดลงที่ Home Screen แล้วพิมพ์ "My Drink" | ปุ่ม **Log Water** ใต้ชื่อ app แตะแล้วบันทึกเลย |
| Siri | พิมพ์หรือพูด "Log water in My Drink" | Siri ตอบด้วย dialog จาก `perform()` |
| Shortcuts | เปิด app Shortcuts → แท็บ App Shortcuts | การ์ด My Drink มี **Log Water** |

!!! tip "ใช้ Type to Siri ในห้องที่เสียงดัง"
    เปิดที่ **Settings → Apple Intelligence & Siri → Talk & Type to Siri** แล้วแตะขอบล่างของจอสองครั้งเพื่อพิมพ์ ถ้า Siri บน iPad ยังไม่รองรับภาษาไทย ให้ตั้งภาษาของ Siri เป็น English แล้วใช้ phrase ภาษาอังกฤษ

## 5. ใช้ intent เดียวกันในปุ่มของ app { #app-button }

`Button(intent:)` ทำให้ปุ่มใน app เรียก intent ตัวเดียวกับที่ Siri ใช้ ใน `ContentView.swift` ลบปุ่ม Water 250 ml เดิม (3 บรรทัดใต้ `TODO Code-along 1`) แล้ว paste โค้ดนี้แทน

```swift
--8<-- "starter/workshop-4/Finished/WaterLog/ContentView.swift:app-button"
```

## ปัญหาที่เจอบ่อย { #troubleshooting }

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| ไม่เห็น action ใน Shortcuts | ระบบยังไม่ได้อ่าน intent ของ build ใหม่ | Run app บน iPad อีกครั้ง แล้วปิดและเปิด Shortcuts ใหม่ ถ้ายังไม่ขึ้น ให้ลบ app แล้ว run ใหม่ |
| Siri ไม่รู้จัก phrase | Siri ใช้ภาษาที่ไม่ตรงกับ phrase หรือพิมพ์ชื่อ app ผิด | ตั้งภาษาของ Siri ให้ตรงกับ phrase และพิมพ์ชื่อ app ให้ตรงกับที่แสดงบน Home Screen |
| `main actor-isolated … cannot be accessed from outside of the actor` หรือ `expression is 'async' but is not marked with 'await'` | `perform()` ไม่ได้อยู่บน main actor | ใส่ `@MainActor` หน้า `func perform()` |
| `Cannot find 'LogWaterIntent' in scope` ใน widget | ไฟล์ไม่ได้อยู่ใน target ของ widget | สร้างไฟล์ไว้ใน `IntentParts/` หรือติ๊ก target ใน **Target Membership** |
| `Cannot find 'Navigator' in scope` หรือ error เดียวกันขึ้น 2 ครั้ง (ใต้ `WaterLog` และ `WaterLogWidgets`) | ไฟล์ในโฟลเดอร์ `WaterLog/` ถูกเพิ่มเข้า widget ด้วย | เลือกไฟล์ → File inspector (⌥⌘1) → **Target Membership** เอาติ๊ก `WaterLogWidgets` ออก |
| Build error เรื่อง `AppShortcutsProvider` ซ้ำ | มี `AppShortcutsProvider` มากกว่า 1 ตัว หรืออยู่ใน widget ด้วย | เก็บไว้ตัวเดียวในโฟลเดอร์ `WaterLog/` |

## ใช้ร่วมกับ

- [Widget และ Control Center](widgets-controls.md): ใช้ `LogWaterIntent` ตัวนี้ในปุ่มของระบบ
- [Tool calling](../workshop-2/tool-calling.md): `Tool` ของ Foundation Models เขียนคล้ายกัน คือมี parameter และฟังก์ชันที่ทำงานจริง

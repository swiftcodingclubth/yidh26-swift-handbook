# ใส่ใน app ของทีม

หน้านี้รวมสิ่งที่ต้องทำเพื่อใส่ App Intents ลงใน project ของทีม ทำตามลำดับ ใช้ได้ทั้ง Xcode 26 และ 27 ยกเว้นส่วน [Siri AI](siri-ai.md)

## 0. ดาวน์โหลด starter project { #get-starter }

Starter project อยู่ในโฟลเดอร์ [`starter/workshop-4`](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-4) ของ repo handbook นี้

| โฟลเดอร์ | ใช้ทำอะไร |
|---|---|
| `Start/` | ใช้ทำ code-along มีหน้าจอ, widget และ App Group พร้อมแล้ว พร้อม `TODO` ตรงที่ต้องเขียนโค้ด |
| `Finished/` | ทำครบทุกหัวข้อแล้ว รวม Siri AI และ AppIntentsTesting ใช้ดูคำตอบหรือ copy ไฟล์ |

1. เปิด [repo handbook](https://github.com/tawapnas/yidh26-swift-handbook) กด **Code → Download ZIP** แล้วแตกไฟล์ (หรือใช้ `git clone` ก็ได้)
2. เปิด `starter/workshop-4/Start/WaterLog.xcodeproj`
3. เลือก **Team** ใน **Signing & Capabilities** ของทุก target (`WaterLog`, `WaterLogWidgets` และ `WaterLogUITests` ใน `Finished`) แล้ว run scheme **WaterLog** บน iPad

ไม่ต้องแก้ Bundle ID หรือ App Group เอง เพราะ project สร้างจาก Team ID ให้อัตโนมัติ (`th.yidh26.waterlog.<Team ID>`) Personal Team ของแต่ละคนจึงได้ ID ที่ไม่ซ้ำกัน `Start` และ `Finished` ใช้ ID เดียวกัน จึงไม่เปลือง App ID ของ Personal Team ที่[สร้างใหม่ได้จำกัดต่อสัปดาห์](../getting-started.md#4-run-app-ipad)

## 1. เลือก action { #pick-action }

เลือก action ที่ผู้ใช้ทำบ่อยที่สุด และทำเสร็จได้ในขั้นเดียว

| เหมาะ | ไม่เหมาะ |
|---|---|
| บันทึกค่า, เริ่ม/หยุด, เช็กอิน, เปิดหน้าหนึ่งในของ app, ถามสรุปของวันนี้ | กรอกฟอร์มยาว, เลือกหลายขั้น, งานที่ต้องดูภาพหรือกล้องตลอดเวลา |

จากนั้นดูว่า app ของทีมเข้ากับ domain ไหนของ Siri AI ในตาราง[App Schema](siri-ai.md#schema) เช่น app โน้ต → `.notes`, app จับเวลาอ่านหนังสือ → `.clock` ถ้าไม่ตรงกับ domain ไหน ใช้ `.system.open` และ `.system.searchInApp` ได้ทุก app

ตัวอย่าง: app ติดตามการกินยา → "Take medicine", app อ่านหนังสือ → "Start reading timer", app สรุปบทเรียนด้วย AI → "Summarize today's notes" แล้วคืนผลเป็น dialog

## 2. Copy ไฟล์ { #files }

ไฟล์ใน `Finished/IntentParts/` เป็นตัวอย่างที่แก้ชื่อแล้วใช้ต่อได้ ลากเข้า Xcode แล้วติ๊ก **Copy items if needed** และเลือกทั้ง target ของ app และ widget extension

| ไฟล์ | เปลี่ยนเป็นของทีม |
|---|---|
| `LogWaterIntent.swift` | ชื่อ action, parameter และโค้ดใน `perform()` ที่เรียก model ของทีม |
| `Beverage+AppEnum.swift` | enum ของทีมที่มีตัวเลือกไม่กี่แบบ |
| `DrinkEntity.swift` | entity และ query จาก model ของทีม |
| `GetTodayDrinksIntent.swift` | intent ที่คืนข้อมูลให้ "Use Model" |
| `WaterLog/WaterShortcuts.swift` | phrase ของทีม (ใส่ใน target ของ app อย่างเดียว) |

`perform()` ต้องเรียกโค้ดเดิมของ app ถ้า model ของทีมทำงานบน main actor ให้ใส่ `@MainActor` หน้า `func perform()` แบบใน starter

## 3. App Group สำหรับ widget และ control { #app-group }

ทำเฉพาะเมื่อต้องการปุ่มใน widget หรือ Control Center ถ้าใช้แค่ Shortcuts, Spotlight และ Siri ข้ามขั้นนี้ได้

1. **File → New → Target → Widget Extension** ติ๊ก **Include Control** แล้วกด **Activate**
2. ที่ target ของ app และ widget: **Signing & Capabilities → + Capability → App Groups** แล้วใช้ ID เดียวกัน เช่น `group.<bundle ID ของ app>`
3. ย้ายข้อมูลไปเก็บใน App Group:
    - UserDefaults: `UserDefaults(suiteName: "group.…")`
    - SwiftData: `ModelConfiguration(groupContainer: .identifier("group.…"))`
4. ไฟล์ intent และ model ที่ widget ใช้ ต้องติ๊กทั้ง 2 target ใน **Target Membership**

## 4. Checklist ทุก surface { #checklist }

Run บน iPad แล้วทดสอบทีละข้อ ข้อที่ผ่านแล้วให้ติ๊ก

- [ ] **Shortcuts**: เพิ่ม action ของ app ใน shortcut ใหม่ได้ และกด ▶︎ แล้วข้อมูลใน app เปลี่ยน
- [ ] **App Shortcuts**: เห็นการ์ดของ app ในแท็บ App Shortcuts ของ Shortcuts
- [ ] **Spotlight**: ค้นชื่อ app แล้วเห็นปุ่ม action แตะแล้วทำงาน
- [ ] **Siri**: พิมพ์ phrase ด้วย Type to Siri แล้ว Siri ตอบด้วย dialog
- [ ] **ปุ่มใน app**: ใช้ `Button(intent:)` ตัวเดียวกัน
- [ ] **Widget** (ไม่บังคับ): กดปุ่มใน widget แล้ว เปิด app เห็นข้อมูลตรงกัน
- [ ] **Control Center** (ไม่บังคับ): เพิ่ม control ได้ และกดแล้วทำงาน
- [ ] **Entity ใน Spotlight**: ค้นข้อมูลใน app เจอ แตะแล้วเปิดหน้านั้น
- [ ] **Use Model**: ส่งผลของ intent ให้ Use Model สรุปได้
- [ ] **Siri AI** ({{ mac.apple }}): ใช้ App Schema, ใส่ `.appEntityIdentifier` และ test ผ่าน

## 5. ให้ agent ช่วย { #agent-prompts }

ใช้ template จาก [Workshop 1](../workshop-1/prompting.md) บอก agent ให้ชัดว่าต้องใช้ App Intents ไม่ใช่ SiriKit แบบเก่า (`INIntent`, `.intentdefinition`) ซึ่ง agent มักเขียนมาให้

### ให้ agent อ่านคู่มือของ Apple ก่อน { #apple-skills }

Apple เขียนคู่มือ App Intents สำหรับ coding agent ไว้ 2 ชุด (agent skill) อยู่ในโฟลเดอร์ [`starter/workshop-4/agent-skills`](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-4/agent-skills) agent ที่อ่านคู่มือนี้จะเขียนโค้ดตาม API ปัจจุบัน และไม่ใช้ API ที่เลิกใช้แล้ว

| Skill | ใช้เมื่อ |
|---|---|
| `app-intents-specialist` | เขียนหรือ review intent, entity, query, `AppEnum` และ phrase (ใช้ได้ทั้ง iOS 26 และ 27) |
| `app-intents-whats-new-27` | ใช้ API ใหม่ของ iOS 26/27 เช่น App Schema (Siri AI), `appEntityIdentifier`, interactive snippet และ AppIntentsTesting |

วิธีใส่ให้ agent:

- **Claude Code**: copy ทั้ง 2 โฟลเดอร์ไปไว้ที่ `.claude/skills/` ใน root ของ project ทีม Claude Code จะอ่านเองเมื่องานเกี่ยวกับ App Intents
- **Agent อื่น** (Codex, Cursor, coding assistant ใน Xcode): copy โฟลเดอร์ไว้ใน project แล้วเพิ่มบรรทัดนี้ใน prompt ทุกครั้ง

```text
ก่อนเขียนโค้ด อ่าน agent-skills/app-intents-specialist/SKILL.md และไฟล์ใน
references/ ที่เกี่ยวกับงานนี้ ถ้าใช้ API ของ iOS 26/27 ให้อ่าน
agent-skills/app-intents-whats-new-27/SKILL.md ด้วย
```

### ตัวอย่าง prompt { #prompt-examples }

```text
Context: SwiftUI app, iOS 26, data อยู่ใน MedicineStore (@MainActor @Observable)
มีตัวอย่างใน IntentParts/LogWaterIntent.swift และ WaterLog/WaterShortcuts.swift
Task: สร้าง TakeMedicineIntent (App Intents framework) รับ parameter medicine
เป็น AppEnum แล้วเรียก MedicineStore.shared.take(_:) และ AppShortcutsProvider
ที่มี phrase "Take my medicine in \(.applicationName)"
Constraints: ห้ามใช้ SiriKit (INIntent, .intentdefinition), perform() ต้องเป็น
@MainActor, ห้ามแก้ MedicineStore, ทำตาม skill app-intents-specialist
Done when: build ผ่าน และเห็น action ใน Shortcuts บน iPad
```

```text
Context: มี LogWaterIntent อยู่แล้ว และมี widget extension WaterLogWidgets
ที่ใช้ App Group เดียวกับ app
Task: เพิ่มปุ่ม Button(intent: LogWaterIntent(milliliters: 250)) ใน widget
และเพิ่ม ControlWidget ที่ใช้ ControlWidgetButton(action:) กับ intent เดียวกัน
Constraints: ห้ามใช้ IntentConfiguration แบบเก่า, ห้ามสร้าง intent ใหม่
Done when: build ผ่าน และกดปุ่มใน widget กับ Control Center แล้วยอดใน app เพิ่ม
```

```text
Context: มี DrinkEntity (AppEntity, IndexedEntity) และ WaterStore
Task: เขียน test ด้วย AppIntentsTesting (iOS 27) ใน UI Testing target ที่ run
LogWaterIntent แล้วเช็กว่า result.value.milliliters ถูกต้อง
Constraints: ห้าม import โค้ดของ app ใน test ใช้ IntentDefinitions(bundleIdentifier:)
และเรียก intent ด้วยชื่อ string, ทำตาม references/testing.md ของ skill
app-intents-whats-new-27
Done when: test ผ่านบน iPad
```

## ปัญหาที่เจอบ่อย { #troubleshooting }

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| `Failed Registering Bundle Identifier` | Bundle ID ซ้ำกับ Personal Team ของคนอื่น | Starter สร้าง ID จาก Team ID ให้แล้ว ใน project ของทีมให้เติมชื่อหรือ Team ID ต่อท้าย Bundle ID |
| Agent เขียน `INIntent` หรือไฟล์ `.intentdefinition` | Agent ใช้ SiriKit แบบเก่า | บอกใน prompt ว่าใช้ App Intents framework ให้ดูไฟล์ใน `IntentParts/` และให้อ่าน [skill ของ Apple](#apple-skills) |
| Action ขึ้นใน Shortcuts 2 ครั้ง | มี intent ชื่อเดียวกันใน app และใน package อื่น | เก็บ intent ไว้ที่เดียว |
| Widget extension build ไม่ผ่านเพราะหา type ใน app ไม่เจอ | ไฟล์ model ไม่ได้อยู่ใน target ของ widget | ติ๊ก target ของ widget ใน **Target Membership** หรือย้ายไปโฟลเดอร์ที่ทั้ง 2 target ใช้ |
| Xcode 26 build ไม่ผ่านหลังเพื่อน push โค้ด Siri AI | ใช้ API ของ iOS 27 โดยไม่ได้ครอบ | ครอบด้วย `#if compiler(>=6.4)` ดู [Siri AI](siri-ai.md) |

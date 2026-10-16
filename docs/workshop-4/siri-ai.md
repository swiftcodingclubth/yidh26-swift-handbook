# Siri AI

!!! mchip "{{ mac.apple }} · Xcode 27"
    App Schema และ AppIntentsTesting เป็น API ใหม่ของ iOS 27 ใช้ได้เฉพาะ Xcode 27 ครอบโค้ดด้วย `#if compiler(>=6.4)` ตาม[วิธีในหน้าเริ่มต้นใช้งาน](../getting-started.md#project-xcode-26-27) เพื่อให้เพื่อนที่ใช้ Xcode 26 ยัง build project ได้ ส่วน [onscreen awareness](#onscreen) ใช้ได้ทั้ง Xcode 26 และ 27

**Siri AI** คือ Siri รุ่นใหม่ใน iOS 27 ที่ใช้ Apple Intelligence คุยด้วยภาษาธรรมดาได้ ไม่ต้องจำคำสั่ง ถามต่อได้หลายรอบ และทำ action ใน app อื่นแทนผู้ใช้ได้ Siri AI ไม่ได้อ่านโค้ดของ app เรา แต่ใช้ intent และ entity ที่เราทำไว้แล้ว ถ้าทำหน้า[App entities](app-entities.md)ครบ app ก็มีพื้นฐานพร้อมแล้ว หน้านี้คือส่วนที่ช่วยให้ Siri เข้าใจ app ได้ดีขึ้น

## Siri AI ทำอะไรได้ { #what-it-does }

| ความสามารถ | ตัวอย่างที่ Apple demo ใน WWDC26 |
|---|---|
| เข้าใจข้อมูลส่วนตัว (personal context) | "Where's Jeff's new place?" Siri หาที่อยู่ที่เพื่อนเคยส่งมาในข้อความ โดยที่ไม่ได้บันทึกไว้ที่ไหน |
| ทำ action ใน app | "Add just the ones with Bryce, Madison, and Quinn to our shared family album" โดยไม่ต้องเปิด Photos |
| รู้ว่าอะไรอยู่บนจอ (onscreen awareness) | ดูรูปอยู่แล้วถาม "Where is this exactly?" |
| เข้าใจภาพ | เปิด Camera ในโหมด Siri แล้วถามเรื่องอาหารหรือแบ่งจ่ายบิล |
| ความรู้ทั่วไป | "What's the schedule for opening weekend of the World Cup?" แล้วคุยต่อจนส่งเมนูปาร์ตี้ให้เพื่อนในกลุ่มแชต |

ทั้งหมดนี้พูดหรือพิมพ์เป็นภาษาธรรมดา และคุยต่อเนื่องได้ ("Cancel it", "Delete the fourth one") ต่างจาก Siri แบบเดิมที่ต้องพูดคำสั่งให้ตรง เช่น "Log water in My Drink"

!!! warning "ข้อจำกัด"
    Siri AI ใช้ได้เฉพาะเครื่องที่รองรับ Apple Intelligence เริ่มต้นเป็นภาษาอังกฤษ และเป็น beta ในปีแรก ผู้เรียนที่ไม่มีเครื่องรองรับยังทำทุกอย่างในหน้านี้ได้ และทดสอบด้วย [AppIntentsTesting](#testing) หรือ Shortcuts แทน

ดู demo จริงได้ใน [WWDC26 Keynote](https://developer.apple.com/videos/play/wwdc2026/101/) ช่วง Siri และ [Platforms State of the Union](https://developer.apple.com/videos/play/wwdc2026/102/) (demo app Origami)

## Siri รู้จัก app ของเราได้อย่างไร { #how }

| Siri ต้องรู้ว่า… | ใช้ | ทำไว้แล้วใน |
|---|---|---|
| App มีข้อมูลอะไร หาได้จากความหมาย | `IndexedEntity` + `indexAppEntities` | [App entities](app-entities.md#spotlight) |
| Action นี้คืองานประเภทไหน | App Schema | [หัวข้อ 1](#schema) |
| ผู้ใช้กำลังดูอะไรอยู่ ("this", "อันนี้") | Onscreen awareness | [หัวข้อ 2](#onscreen) |

## 1. บอก Siri ว่า action คืองานประเภทไหน: App Schema { #schema }

**App Schema** คือรูปแบบ intent และ entity มาตรฐานที่ Siri เข้าใจอยู่แล้ว เช่น "ส่งข้อความ", "สร้าง event" หรือ "เปิดสิ่งนี้" ถ้า action ของเราตรงกับ schema Siri จะใช้ action นั้นได้จากคำพูดหลายแบบ โดยเราไม่ต้องเขียน phrase เอง Schema แบ่งเป็นกลุ่มตามประเภทของ app (domain)

| ถ้า app ของทีมเป็น… | Domain |
|---|---|
| ปฏิทิน นัดหมาย, นาฬิกา ปลุก จับเวลา | `.calendar`, `.clock` |
| โน้ต บันทึกประจำวัน, สิ่งที่ต้องทำ | `.notes`, `.journal`, `.reminders` |
| แชต อีเมล โทร | `.messages`, `.mail`, `.phone` |
| รูปภาพ กล้อง | `.photos`, `.camera` |
| เพลง podcast เสียง | `.audio` |
| แผนที่ การเดินทาง | `.maps` |
| อ่านหนังสือ เอกสาร ไฟล์ | `.books`, `.reader`, `.files` |
| งานเอกสาร | `.wordProcessor`, `.spreadsheet`, `.presentation`, `.whiteboard` |
| เว็บ | `.browser` |
| ทุก app | `.system` (`.open`, `.searchInApp`) |

รายการนี้มาจาก iOS 27 SDK (Xcode 27.1) ถ้า app ของทีมเข้ากับ domain ไหน Siri AI จะเข้าใจคำพูดหลายรูปแบบได้เองมากที่สุด ทั้งถาม ทำ และแก้ไข

My Drink ไม่ตรงกับ domain ไหน จึงใช้ `.system.open` ซึ่งทุก app ใช้ได้ `OpenDrinkIntent` เวอร์ชันนี้อยู่ใน `Finished/WaterLog/SiriAI/`

```swift
--8<-- "starter/workshop-4/Finished/WaterLog/SiriAI/OpenDrinkIntent+Schema.swift:schema"
```

Schema กำหนด title และ parameter ไว้ให้แล้ว เราจึงไม่ต้องเขียน `title` หรือ `@Parameter` เอง ถ้าเขียนไม่ตรงกับ schema Xcode จะแสดง error พร้อม Fix-It ให้ เพราะ entity หนึ่งตัวมี `OpenIntent` ได้ตัวเดียว starter จึงใช้ `#if` เลือกว่าจะใช้เวอร์ชันไหน

My Drink ใช้ `.system.searchInApp` ด้วย ผู้ใช้จึงพูดว่า "Search My Drink for coffee" แล้ว app จะเปิดพร้อมผลค้นหา

```swift
--8<-- "starter/workshop-4/Finished/WaterLog/SiriAI/SearchDrinksIntent.swift:search"
```

!!! tip "ให้ Xcode สร้างโค้ดให้"
    พิมพ์ `@AppIntent(schema: .` หรือ `@AppEntity(schema: .` แล้วเลือก schema จาก code completion Xcode จะสร้างโค้ดตั้งต้นพร้อม parameter ที่ schema ต้องการ วิธีนี้แม่นกว่าให้ agent เขียนเอง เพราะ agent ส่วนใหญ่ยังไม่รู้จัก schema ของ iOS 27

## 2. บอก Siri ว่าผู้ใช้กำลังดูอะไร: Onscreen awareness { #onscreen }

ถ้าผู้ใช้พูดว่า "this", "อันนี้" หรือ "อันที่สาม" Siri ต้องรู้ว่าบนจอมี entity อะไรอยู่ ใช้ modifier 2 ตัว

**หน้าที่เป็นรายการ**: ใส่ `.appEntityIdentifier` ที่แต่ละแถว Siri จะรู้ว่ามีแก้วไหนอยู่บนจอ และเข้าใจ "open the second one"

```swift
--8<-- "starter/workshop-4/Finished/WaterLog/ContentView.swift:annotate"
```

**หน้าที่แสดงอย่างเดียวเป็นหลัก** (หน้า detail): ใส่ `.userActivity` แล้วกำหนด `appEntityIdentifier` Siri จะรู้ว่า "this" คือแก้วนี้

```swift
--8<-- "starter/workshop-4/Finished/WaterLog/ContentView.swift:detail"
```

ทั้งสองแบบใช้ได้ตั้งแต่ iOS 18 จึงใช้ได้ทั้ง Xcode 26 และ 27 ลองบน iPad: เปิดหน้า detail ของกาแฟแก้วหนึ่ง แล้วพิมพ์กับ Siri ว่า "How much was this?"

## 3. ทดสอบ intent ด้วย AppIntentsTesting { #testing }

**AppIntentsTesting** run intent ผ่านระบบจริงแบบเดียวกับที่ Siri และ Shortcuts ใช้ แต่สั่งจากโค้ดใน UI Testing target จึงไม่ต้องพูดกับ Siri ทุกครั้งที่แก้โค้ด Test เรียก intent และ entity ด้วยชื่อที่เป็น string ไม่ได้ import โค้ดของ app

```swift
--8<-- "starter/workshop-4/Finished/WaterLogUITests/WaterLogIntentTests.swift:test"
```

1. เปิด `Finished/WaterLog.xcodeproj` แล้วเลือก Team เดียวกันในทั้ง 3 target (รวม `WaterLogUITests`)
2. เลือก iPad เป็น run destination แล้วกด ++cmd+u++
3. ดูผลใน Test navigator (++cmd+6++)

Parameter ที่เป็น `AppEnum` ส่งเป็น raw value ได้เลย เช่น `beverage: "tea"` และผลที่ได้อ่านเป็น property ได้ตรงๆ เช่น `result.value.milliliters`

## 4. ลองกับ Siri { #try-siri }

Run app บน iPad บันทึกเครื่องดื่ม 2–3 แก้ว แล้วลองพิมพ์ด้วย Type to Siri

| ลองพิมพ์ | สิ่งที่ Siri ใช้ |
|---|---|
| "Open my last coffee in My Drink" | `IndexedEntity` + `OpenDrinkIntent` |
| เปิดหน้า detail ของแก้วหนึ่ง แล้วพิมพ์ "How much was this?" | Onscreen awareness |
| "Search My Drink for coffee" | `SearchDrinksIntent` (`.system.searchInApp`) |
| "Log a tea in My Drink" | App Shortcut phrase |

ผลของ Siri AI ขึ้นกับภาษาและภูมิภาคที่ตั้งไว้ใน iPad ก่อน demo ให้ทดสอบกับ iPad เครื่องที่จะใช้จริง และเตรียม Shortcuts ไว้เป็นทางสำรอง

## ปัญหาที่เจอบ่อย { #troubleshooting }

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| `'open' is only available in iOS 27.0 or newer` | Deployment target เป็น iOS 26 | ใส่ `@available(iOS 27.0, *)` ที่ intent |
| Xcode 26 build ไม่ผ่านเพราะ `@AppIntent(schema:)` | Xcode 26 ไม่มี API ของ iOS 27 | ครอบด้วย `#if compiler(>=6.4)` |
| `OpenIntent targets should be unique` | มี `OpenIntent` แบบธรรมดาและแบบ schema พร้อมกัน | ใช้ `#if compiler(>=6.4)` / `#if !compiler(>=6.4)` แบบใน starter |
| Test error `<bundle ID> is not present` | ระบบยังไม่รู้จัก app หรือ app กับ test ใช้ Team ต่างกัน | Run test บน iPad จริง และเลือก Team เดียวกันทุก target |
| Siri ไม่เข้าใจคำว่า "this" | View ไม่มี `.appEntityIdentifier` | ดู [หัวข้อ 2](#onscreen) |

## ไปต่อ { #next }

- **Interactive snippet** (iOS 26): แสดง SwiftUI view ที่มีปุ่มในผลของ Siri ด้วย `SnippetIntent`
- **Undo** (iOS 26): ให้ผู้ใช้ย้อน action ที่ Siri ทำได้ด้วย `UndoableIntent`
- **Visual intelligence**: ให้ผู้ใช้ค้นหาข้อมูลใน app จากสิ่งที่กล้องเห็น
- **ความปลอดภัย**: intent ที่ AI เรียกได้อาจถูกหลอกด้วย prompt injection ให้ขอการยืนยันก่อนทำ action ที่ย้อนกลับไม่ได้ ดู [Secure your app: mitigate risks to agentic features](https://developer.apple.com/videos/play/wwdc2026/347/)
- WWDC26: [Build intelligent Siri experiences with App Schemas](https://developer.apple.com/videos/play/wwdc2026/240/), [Code-along: Make your app available to Siri](https://developer.apple.com/videos/play/wwdc2026/344/), [Validate your App Intents adoption with AppIntentsTesting](https://developer.apple.com/videos/play/wwdc2026/295/), [What's new in Shortcuts](https://developer.apple.com/videos/play/wwdc2026/310/)

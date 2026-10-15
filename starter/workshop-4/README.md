# Workshop 4 starter: App Intents

Starter project ของ Workshop 4 · app ตัวอย่างชื่อ **My Drink** (บันทึกการดื่มน้ำ) · iOS 26 · ไม่มี dependency ภายนอก · เปิดได้ทั้ง Xcode 26 และ 27

## เริ่มใช้งาน

1. เปิด `Start/WaterLog.xcodeproj` (ทำตามใน workshop) หรือ `Finished/WaterLog.xcodeproj` (เฉลย)
2. เลือก **Team** ใน **Signing & Capabilities** ของทุก target: `WaterLog`, `WaterLogWidgets` (และ `WaterLogUITests` ใน `Finished`)
3. เลือก iPad เป็น run destination แล้ว run scheme **WaterLog** ชื่อ app บน Home Screen คือ **My Drink**

หน้าจอใช้ Liquid Glass ของ iOS 26 (`glassEffect`, `GlassEffectContainer`, `.buttonStyle(.glass)`) มีวงแหวนยอดของวันนี้ ปุ่มเพิ่มด่วน 6 แบบ และรายการที่ดื่มวันนี้

Bundle ID และ App Group สร้างจาก Team ID อัตโนมัติ (`th.yidh26.waterlog.<Team ID>` และ `group.th.yidh26.waterlog.<Team ID>`) จึงไม่ต้องแก้เอง และไม่ชนกับ Personal Team ของเพื่อน ดู build setting `WATERLOG_BUNDLE_ID` และ `WATERLOG_APP_GROUP` ที่ระดับ project

## โครงสร้าง

| โฟลเดอร์ | Target | เนื้อหา |
|---|---|---|
| `WaterLog/` | app | หน้าจอ, `WaterShortcuts`, `OpenDrinkIntent` และ `SiriAI/` (Xcode 27: `OpenDrinkIntent` แบบ schema และ `SearchDrinksIntent`) |
| `WaterLogWidgets/` | widget extension | Widget "Water Today" ที่มีปุ่ม 250 ml และ control ใน Control Center |
| `Shared/` | ทั้งสอง | `Drink`, `Beverage`, `WaterStore` (เก็บข้อมูลใน App Group) และสี/ไอคอน/วงแหวนใน `Drink+Style.swift` |
| `IntentParts/` | ทั้งสอง | Intent, entity และ enum ที่ copy ไปใส่ app ของทีมได้ |
| `WaterLogUITests/` | UI test (เฉพาะ `Finished`) | Test ด้วย AppIntentsTesting (Xcode 27, run บน iPad) |
| `Config/` | - | Entitlements และ Info.plist ที่อ่าน App Group ID จาก build setting |
| `agent-skills/` | - | คู่มือ App Intents ที่ Apple เขียนให้ coding agent อ่าน (`app-intents-specialist`, `app-intents-whats-new-27`) ดูวิธีใช้ในหน้า "ใส่ใน app ของทีม" |

ไฟล์ใหม่ที่ widget ต้องใช้ ให้สร้างใน `IntentParts/` หรือ `Shared/` จะได้อยู่ในทั้งสอง target อัตโนมัติ

## `Start`: ตำแหน่ง TODO

ทุกขั้น copy โค้ดจากหน้า Workshop 4 ใน handbook มา paste ไม่ต้องพิมพ์เอง `TODO Code-along N` บอกตำแหน่งที่ต้อง paste

| TODO | หน้าใน handbook และไฟล์ |
|---|---|
| 1. Intent แรก | สร้าง `IntentParts/LogWaterIntent.swift`, `WaterLog/WaterShortcuts.swift` และแก้ปุ่ม Water 250 ml ใน `ContentView.swift` |
| 2. Widget และ Control Center (ไม่บังคับ ผู้บรรยาย demo จาก `Finished`) | `WaterLogWidgets/WaterWidget.swift`, สร้าง `LogWaterControl.swift`, `WaterLogWidgetsBundle.swift` |
| 3. App entities | สร้างไฟล์ใน `IntentParts/` และ `WaterLog/OpenDrinkIntent.swift`, แทน `LogWaterIntent.swift` และ `WaterShortcuts.swift` ด้วยเวอร์ชันเต็ม, เอา comment ออกใน `Shared/WaterStore.swift` |

## ตามไม่ทัน

Copy ไฟล์ทั้งหมดใน `Finished/IntentParts/` และ `Finished/WaterLog/WaterShortcuts.swift` ไปใส่ `Start` แล้วเอา comment ออกจากบรรทัด `TODO Code-along 3` ใน `Shared/WaterStore.swift` หรือเปิด `Finished` แทน

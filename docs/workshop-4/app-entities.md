# App entities

**App Entity** คือข้อมูลใน app ที่ทำเป็นแบบที่ระบบรู้จัก เช่น เครื่องดื่มหนึ่งแก้ว, โน้ตหนึ่งอัน หรือบทเรียนหนึ่งบท เมื่อ intent รับหรือคืนค่าเป็น entity ได้ Shortcuts จะส่งข้อมูลต่อให้ action อื่นได้ Spotlight ค้นหาเจอ และ Siri กับ "Use Model" อ่านข้อมูลนั้นได้ ใช้ได้ทั้ง Xcode 26 และ 27

ใช้ทำอะไรได้: ค้นหาบันทึกของ app จาก Spotlight, ให้ AI สรุปข้อมูลของวันนี้ใน Shortcuts, ให้ผู้ใช้เลือกรายการใน Shortcuts, ให้ Siri ตอบคำถามจากข้อมูลใน app

Entity ไม่ได้แทนที่ data model เดิม `Drink` ยังเป็น source of truth ส่วน `DrinkEntity` เป็นแค่ข้อมูลที่ส่งให้ระบบ

ทุกขั้นในหน้านี้เป็นการ paste ทั้งไฟล์ ไม่ต้องแก้โค้ดทีละบรรทัด

## 1. ตัวเลือกที่มีจำนวนจำกัด: AppEnum { #app-enum }

ถ้า parameter มีค่าให้เลือกไม่กี่แบบ ให้ทำ enum เดิมของ app ให้ conform `AppEnum` (raw value ต้องเป็น `String`) สร้างไฟล์ `IntentParts/Beverage+AppEnum.swift` แล้ว paste โค้ดนี้ทั้งหมด

```swift
--8<-- "starter/workshop-4/Finished/IntentParts/Beverage+AppEnum.swift"
```

โค้ดนี้ทำอะไร: `caseDisplayRepresentations` คือชื่อและไอคอนของแต่ละตัวเลือก Shortcuts จะแสดงเป็นรายการให้เลือก และ Siri จะรู้จักคำว่า "coffee" หรือ "tea"

## 2. ทำ entity { #entity }

สร้างไฟล์ `IntentParts/DrinkEntity.swift` แล้ว paste โค้ดนี้ทั้งหมด ไฟล์นี้มี 3 ส่วน: entity, query และโค้ดส่งข้อมูลเข้า Spotlight

```swift
--8<-- "starter/workshop-4/Finished/IntentParts/DrinkEntity.swift"
```

`DrinkEntity` ต้องมี 4 อย่าง

| ส่วน | หน้าที่ |
|---|---|
| `id` | ใช้หา `Drink` ตัวจริงใน `WaterStore` |
| `typeDisplayRepresentation` | ชื่อประเภท เช่น "Drink" |
| `@Property` | **ข้อมูลที่ระบบมองเห็น** ถ้าไม่ได้ใส่ property ไหน Shortcuts, Siri และ "Use Model" จะไม่รู้เรื่องนั้นเลย |
| `displayRepresentation` | หน้าตาของแต่ละแก้วใน Spotlight และ Shortcuts |

## 3. ให้ระบบหา entity เจอ: EntityQuery { #query }

ระบบเก็บแค่ `id` ของ entity ไว้ เมื่อต้องใช้จะขอ entity ตัวเต็มจาก app ผ่าน `DrinkQuery` ในไฟล์เดียวกัน

| Method | ระบบเรียกเมื่อ |
|---|---|
| `entities(for:)` | ต้องการ entity ตาม id ที่เก็บไว้ เช่น shortcut ที่ผู้ใช้สร้างไว้ |
| `suggestedEntities()` | แสดงรายการให้เลือกใน Shortcuts |
| `entities(matching:)` | ผู้ใช้พิมพ์หรือพูดชื่อ ต้อง conform `EntityStringQuery` |

## 4. ส่ง entity เข้า Spotlight { #spotlight }

`IndexedEntity` ทำให้ entity เข้าไปอยู่ใน Spotlight index ของเครื่อง ผู้ใช้ค้นหาเจอได้ทั้งใน Spotlight และ Siri แต่ conform อย่างเดียวยังไม่พอ ต้องส่งข้อมูลเข้า index ทุกครั้งที่สร้างหรือลบด้วย ซึ่งคือ `SpotlightIndex` ท้ายไฟล์ `DrinkEntity.swift`

1. ใน `Shared/WaterStore.swift` ลบ `// TODO Code-along 3: ` ออก 2 ที่ ให้เหลือ `SpotlightIndex.add(drink)` และ `SpotlightIndex.remove(drink)`
2. เปิด `IntentParts/LogWaterIntent.swift` ลบโค้ดเดิมทั้งหมด แล้ว paste เวอร์ชันเต็มนี้แทน

```swift
--8<-- "starter/workshop-4/Finished/IntentParts/LogWaterIntent.swift"
```

เวอร์ชันนี้ต่างจาก[เวอร์ชันแรก](first-intent.md#first-intent) 2 อย่าง: มี parameter `beverage` ที่ใช้ `Beverage` จากขั้นที่ 1 และคืน `DrinkEntity` กลับมาด้วย (`ReturnsValue<DrinkEntity>`) action อื่นใน Shortcuts จึงใช้แก้วที่เพิ่งบันทึกต่อได้

## 5. แตะผลค้นหาแล้วเปิด app { #open }

เมื่อผู้ใช้แตะ drink ใน Spotlight ระบบจะหา intent ที่ conform `OpenIntent` ของ entity นั้น แล้วเปิด app ไปที่ drink นั้น สร้างไฟล์ `WaterLog/OpenDrinkIntent.swift` (ในโฟลเดอร์ของ app เพราะต้องเปิด app) แล้ว paste โค้ดนี้ทั้งหมด ติ๊ก target `WaterLog` อย่างเดียว ถ้าขึ้น `Cannot find 'Navigator' in scope` ให้เอาติ๊ก `WaterLogWidgets` ออกใน **Target Membership** (⌥⌘1)

```swift
import AppIntents

--8<-- "starter/workshop-4/Finished/WaterLog/OpenDrinkIntent.swift:open"
```

`Navigator` มีอยู่แล้วใน starter เมื่อ `openDrink` เปลี่ยน app จะเปิดหน้า detail ของแก้วนั้น Entity หนึ่งตัวมี `OpenIntent` ได้ตัวเดียว ใน `Finished` บน Xcode 27 จะใช้เวอร์ชัน App Schema แทน ดู [Siri AI](siri-ai.md#schema)

## 6. ส่งข้อมูลให้ "Use Model" ใน Shortcuts { #use-model }

**Use Model** คือ action ใน Shortcuts ที่ส่งข้อมูลให้ Apple Intelligence model ประมวลผล เลือกได้ว่าจะ run บน iPad (On-Device) หรือบน Private Cloud Compute ถ้า intent ของเราคืน entity มา model จะเห็นทุก `@Property` ของ entity นั้น

สร้างไฟล์ `IntentParts/GetTodayDrinksIntent.swift` แล้ว paste โค้ดนี้ทั้งหมด intent นี้คืนรายการที่ดื่มวันนี้เป็น `[DrinkEntity]`

```swift
--8<-- "starter/workshop-4/Finished/IntentParts/GetTodayDrinksIntent.swift"
```

แล้วเปิด `WaterLog/WaterShortcuts.swift` ลบโค้ดเดิมทั้งหมด แล้ว paste เวอร์ชันเต็มนี้แทน เพื่อเพิ่ม phrase ที่ใช้ชื่อเครื่องดื่ม และ phrase ถามยอดของวันนี้

```swift
--8<-- "starter/workshop-4/Finished/WaterLog/WaterShortcuts.swift"
```

Run app แล้วลองสร้าง shortcut บน iPad

1. Shortcuts → **+** → เพิ่ม action **Get Today's Drinks** ของ My Drink
2. เพิ่ม action **Use Model** → เลือก **On-Device**
3. Prompt: "เป้าหมายคือ 2000 ml จากรายการนี้ วันนี้ดื่มน้ำพอหรือยัง แนะนำสั้นๆ 1 ประโยค" แล้วแทรกผลของ Get Today's Drinks
4. เพิ่ม action **Show Content** แล้วกด ▶︎

ถ้า model ตอบผิด ให้ดูว่า model ได้ข้อมูลอะไรไปบ้าง: เลือก output **Transcript** ของ Use Model ใน Show Content (iPadOS 27) ถ้าข้อมูลที่ต้องใช้ไม่อยู่ในนั้น ให้เพิ่มเป็น `@Property` ของ entity

## ปัญหาที่เจอบ่อย { #troubleshooting }

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| ค้นใน Spotlight ไม่เจอ drink | ยังไม่ได้เรียก `indexAppEntities` หรือบันทึกก่อนที่จะเพิ่มโค้ด index | เอา comment ออกจาก `SpotlightIndex.add` แล้วบันทึกแก้วใหม่ |
| แตะผลใน Spotlight แล้วเปิด app แต่ไม่ไปที่ drink | ไม่มี `OpenIntent` ของ entity นั้น | ดู [แตะผลค้นหาแล้วเปิด app](#open) |
| `OpenIntent targets should be unique` | มี `OpenIntent` 2 ตัวที่ใช้ entity เดียวกัน | เก็บไว้ตัวเดียว หรือครอบด้วย `#if` แบบใน starter |
| "Use Model" ตอบโดยไม่สนข้อมูลบางอย่าง | ข้อมูลนั้นไม่ได้เป็น `@Property` | เพิ่ม `@Property` แล้วดู Transcript อีกครั้ง |
| Parameter ใน phrase ไม่ทำงาน | ใช้ parameter ที่ไม่ใช่ `AppEnum` หรือ entity | Phrase ใส่ได้เฉพาะ parameter ที่เป็น `AppEnum` หรือ `AppEntity` |

!!! danger "ข้อมูลสุขภาพ"
    ปริมาณน้ำที่ดื่มเป็นข้อมูลสุขภาพ ระหว่าง hackathon ให้ใช้ข้อมูลที่สร้างขึ้นเองเท่านั้น และข้อมูลที่ส่งเข้า Spotlight จะค้นเจอได้จากทั้งเครื่อง จึงไม่ควร index ข้อมูลที่ผู้ใช้ไม่อยากให้คนอื่นเห็นตอนยืม iPad

## ใช้ร่วมกับ

- [Foundation Models](../workshop-2/foundation-models.md): ถ้าอยากให้ AI สรุปใน app เอง แทนการใช้ "Use Model" ใน Shortcuts
- [Siri AI](siri-ai.md): ใช้ entity ชุดนี้ต่อกับ App Schema และ onscreen awareness

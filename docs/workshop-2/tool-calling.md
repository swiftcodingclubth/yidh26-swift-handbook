# Tool calling

Model ไม่รู้ข้อมูลใน app ของเรา เช่น วันที่วันนี้ ข้อมูลใน SwiftData หรือตำแหน่งผู้ใช้ และทำอะไรใน app เองไม่ได้ **Tool** คือฟังก์ชันที่เราเขียนให้ model เรียกได้เมื่อต้องการข้อมูลหรืออยากให้เกิด action

ขั้นตอนที่เกิดขึ้นเมื่อส่ง prompt:

1. Model อ่าน prompt แล้วดูรายการ tool ที่มีจาก `name` และ `description`
2. ถ้าต้องใช้ข้อมูลเพิ่ม model จะเรียก tool พร้อม argument ที่มันเลือกเอง
3. Framework run ฟังก์ชัน `call(arguments:)` ของเรา แล้วส่งผลลัพธ์กลับไปให้ model
4. Model ใช้ผลลัพธ์นั้นเขียนคำตอบสุดท้าย

ทั้งหมดเกิดใน `respond(to:)` ครั้งเดียว เราไม่ต้องเขียนโค้ดจัดการขั้นตอนเหล่านี้เอง ใช้ได้ทั้ง Xcode 26 และ 27 กับ on-device model ส่วน tool calling กับ AI cluster ต้องใช้ Xcode 27 ดู[ใช้ AI cluster ใน session](hackathon-ai.md#model-session)

## 1. Tool ที่ไม่ต้องรับข้อมูล

Tool ที่ง่ายที่สุดคืนข้อมูลที่ model ไม่มีทางรู้เอง เช่น วันที่วันนี้ `Arguments` ว่างเพราะ model ไม่ต้องส่งอะไรมา

```swift
struct TodayTool: Tool {
    let name = "today"
    let description = "วันที่ปัจจุบัน"

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> String {
        Date.now.formatted(date: .complete, time: .omitted)
    }
}

let session = LanguageModelSession(tools: [TodayTool()])
let reply = try await session.respond(to: "อีกกี่วันจะถึงวันศุกร์")
```

## 2. Tool ที่รับข้อมูลจาก model

`Arguments` เป็น `@Generable` struct ใส่ property ที่ต้องการให้ model กรอกมา และใช้ `@Guide` บอกว่าแต่ละช่องคืออะไร ตัวอย่างนี้ให้ model ค้นโน้ตใน app ด้วย keyword ที่มันเลือกจากคำถามของผู้ใช้

```swift
struct Note: Sendable {
    let title: String
    let body: String
}

struct SearchNotesTool: Tool {
    let name = "searchNotes"
    let description = "ค้นโน้ตของผู้ใช้ด้วย keyword แล้วคืนโน้ตที่เกี่ยวข้อง"

    let notes: [Note]   // ข้อมูลจาก app เช่น ดึงมาจาก SwiftData

    @Generable
    struct Arguments {
        @Guide(description: "คำสำคัญที่ใช้ค้น เช่น ชื่อวิชาหรือหัวข้อ")
        var keyword: String
    }

    func call(arguments: Arguments) async throws -> String {
        let found = notes.filter {
            $0.title.localizedCaseInsensitiveContains(arguments.keyword) ||
            $0.body.localizedCaseInsensitiveContains(arguments.keyword)
        }
        if found.isEmpty { return "ไม่พบโน้ตที่เกี่ยวกับ \(arguments.keyword)" }
        return found.map { "\($0.title): \($0.body)" }.joined(separator: "\n")
    }
}

let session = LanguageModelSession(
    tools: [SearchNotesTool(notes: myNotes)],
    instructions: "ตอบจากโน้ตของผู้ใช้เท่านั้น ถ้าไม่พบให้บอกตรงๆ")
let reply = try await session.respond(to: "สัปดาห์ก่อนจดอะไรเรื่อง SwiftUI ไว้บ้าง")
```

ถ้าไม่พบข้อมูล ให้คืนข้อความบอก model ตรงๆ แทนการ `throw` model จะได้ตอบผู้ใช้ได้ว่าไม่มี

## 3. Tool ที่ทำ action ใน app

Tool ไม่ได้มีไว้แค่อ่านข้อมูล ยังเปลี่ยนข้อมูลใน app ได้ด้วย ตัวอย่างนี้ให้ model เพิ่ม task ลงรายการ ผู้ใช้พิมพ์เป็นประโยคธรรมดา แล้ว model แยกเป็น task ให้เอง

```swift
@Observable @MainActor
final class TaskStore {
    var tasks: [String] = []
    func add(_ title: String) { tasks.append(title) }
}

struct AddTaskTool: Tool {
    let name = "addTask"
    let description = "เพิ่ม task หนึ่งรายการลงใน to-do list ของผู้ใช้"

    let store: TaskStore

    @Generable
    struct Arguments {
        @Guide(description: "ชื่อ task สั้นๆ ขึ้นต้นด้วยคำกริยา")
        var title: String
    }

    func call(arguments: Arguments) async throws -> String {
        await store.add(arguments.title)
        return "เพิ่ม \(arguments.title) แล้ว"
    }
}

let session = LanguageModelSession(tools: [AddTaskTool(store: store)])
try await session.respond(to: "พรุ่งนี้ต้องส่งการบ้านเลข ซื้อนม แล้วก็โทรหาแม่")
// store.tasks: ["ส่งการบ้านเลข", "ซื้อนม", "โทรหาแม่"]
```

Model เรียก tool ได้หลายครั้งในคำตอบเดียว ที่นี่จึงได้ 3 task จากประโยคเดียว และเพราะ `TaskStore` เป็น `@Observable` รายการใน SwiftUI จะอัปเดตเอง

!!! warning "Action ที่ย้อนกลับไม่ได้"
    ถ้า tool ลบข้อมูล ส่งข้อความ หรือจ่ายเงิน ให้ถามผู้ใช้ยืนยันก่อนเสมอ อย่าให้ model ทำเองทันที

## 4. หลาย tool ใน session เดียว

ส่ง tool หลายตัวพร้อมกันได้ model จะเลือกเองว่าคำถามไหนต้องใช้ตัวไหน หรือใช้หลายตัวต่อกัน ช่วยให้เลือกถูกด้วย `description` ที่ชัด และบอกใน `instructions` ว่าเมื่อไหร่ควรใช้ tool ไหน

```swift
let session = LanguageModelSession(
    tools: [
        TodayTool(),
        SearchNotesTool(notes: myNotes),
        AddTaskTool(store: store)
    ],
    instructions: """
        คุณคือผู้ช่วยจัดการการเรียน
        ใช้ searchNotes เมื่อผู้ใช้ถามถึงเนื้อหาที่เคยจด
        ใช้ addTask เมื่อผู้ใช้บอกสิ่งที่ต้องทำ
        """)

try await session.respond(to: "ดูโน้ตเรื่อง Git ให้หน่อย แล้วเพิ่ม task ให้ทบทวนก่อนวันศุกร์")
// Model เรียก searchNotes → today → addTask แล้วสรุปให้ผู้ใช้
```

!!! tip "เขียน tool ให้ model ใช้ถูก"
    - `name` และ `description` คือสิ่งเดียวที่ model รู้เกี่ยวกับ tool เขียนให้ชัดว่า tool ทำอะไรและควรใช้เมื่อไหร่
    - ให้ tool หนึ่งตัวทำงานเดียว ดีกว่าทำหลายอย่างในตัวเดียว
    - คืนผลลัพธ์สั้นๆ เฉพาะที่ model ต้องใช้ ข้อความยาวทำให้ช้าและกิน context
    - On-device model เล็ก ใส่ tool ไม่เกิน 3–5 ตัวต่อ session
    - Model ของงานใช้ tool ได้เฉพาะตัวที่ช่อง "ทำอะไรได้" มี tool calling ดู[ตาราง model](hackathon-ai.md#models)

# Foundation Models

**Foundation Models** คือ framework ของ Apple สำหรับใช้ language model ใน app หัวใจของมันคือ `LanguageModelSession` ซึ่งเป็นตัวแทนของ "บทสนทนา" หนึ่งครั้งกับ model: เราส่ง prompt เข้าไป แล้วได้คำตอบกลับมา

ใช้ได้ทั้ง Xcode 26 และ 27 โค้ดทุกตัวอย่างในหน้านี้ใช้กับ on-device AFM 3 และใช้กับ model บน cluster ได้เหมือนกันเมื่อ[เปลี่ยน model](hackathon-ai.md)

!!! intel "{{ mac.intel }} · Xcode 26"
    Simulator บน {{ mac.intel }} ไม่รองรับ Apple Intelligence ให้ run บน iPad เสมอ

## ถาม-ตอบ

สร้าง session พร้อม `instructions` ซึ่งเป็นคำสั่งที่ model จะยึดตลอดบทสนทนา เช่น ภาษาและรูปแบบคำตอบ จากนั้นเรียก `respond(to:)` เพื่อส่ง prompt การเรียก model ใช้เวลา จึงต้องใช้ `try await`

```swift
import FoundationModels

let session = LanguageModelSession(
    instructions: "ตอบเป็นภาษาไทย สั้นและชัดเจน")

let response = try await session.respond(to: "สรุปข้อความนี้: \(text)")
print(response.content)   // ข้อความที่ model ตอบ
```

Session **สามารถจำบทสนทนาก่อนหน้าได้** ถ้าถามคำถามต่อใน session เดิม model จะรู้ว่าคุยอะไรกันมาแล้ว ถ้าจะเริ่มเรื่องใหม่ที่ไม่เกี่ยวกัน ให้สร้าง session ใหม่

## Streaming

`respond(to:)` จะรอจนได้คำตอบทั้งหมดก่อน ถ้าคำตอบยาว ผู้ใช้จะเห็นหน้าจอว่างอยู่หลายวินาที `streamResponse(to:)` จะส่งคำตอบมาทีละส่วนระหว่างที่ model กำลังเขียน ทำให้ app รู้สึกเร็วขึ้นมาก

```swift
let stream = session.streamResponse(to: prompt)
for try await partial in stream {
    output = partial.content   // คำตอบทั้งหมดที่ได้มาถึงตอนนี้
}
```

## `@Generable`: ให้ model ตอบเป็น Structured output

ถ้าต้องการข้อมูลไปใช้ทำงานต่อในโค้ด เช่น แสดงข้อมูลเป็นรายการหรือเก็บลงฐานข้อมูล การได้คำตอบเป็นข้อความยาวๆ แล้วมานั่ง parse ข้อมูลเอง มีโอกาสจะพังได้ง่าย การใช้ `@Generable` จะบังคับให้ model ตอบตามโครงสร้างนั้นทุกครั้ง

ใช้ `@Guide` อธิบายแต่ละ property ให้ model เข้าใจว่าควรใส่อะไร หรือกำหนดเงื่อนไข เช่น จำนวนข้อ

```swift
@Generable
struct Quiz {
    @Guide(description: "คำถามสั้นๆ จากเนื้อหา")
    var question: String
    @Guide(description: "ตัวเลือก 4 ข้อ", .count(4))
    var choices: [String]
    var answerIndex: Int
}

let quiz = try await session.respond(
    to: "สร้าง quiz จาก lecture นี้: \(notes)",
    generating: Quiz.self
).content

quiz.choices   // [String] ใช้ใน List ได้ทันที
```

## Tool calling

ถ้าต้องการให้ model ใช้ข้อมูลใน app หรือสั่งให้ app ทำอะไรบางอย่าง เช่น ค้นโน้ตหรือเพิ่ม task ให้ใช้ tool calling ดูตัวอย่างทั้งหมดในหน้า [Tool calling](tool-calling.md)

!!! tip "ให้ model ทำงานน้อยลง ได้ผลดีขึ้น"
    - เขียน `instructions` สั้นและเจาะจง บอกว่าต้องการอะไร ไม่ใช่แค่ว่าเป็นใคร
    - ใช้ `@Generable` แทนการขอให้ model ตอบเป็น JSON ในข้อความ
    - แบ่งงานใหญ่เป็นหลาย request เล็กๆ เช่น สรุปก่อน แล้วค่อยสร้าง quiz จากสรุป

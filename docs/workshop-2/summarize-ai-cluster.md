# แบบฝึกหัด: สรุปโน้ตด้วย AI cluster

ปุ่ม **สรุป** ใน app **StudyNotes** ตอนนี้ใช้ on-device model แบบฝึกหัดนี้เปลี่ยนให้ไปเรียก Smart Route บน [AI cluster](hackathon-ai.md) แทน แก้แค่ฟังก์ชัน `summarize` ใน `NoteAssistant.swift` ส่วน UI และสวิตช์ Precise / Creative ใช้ได้เหมือนเดิม

ใช้ได้ทั้ง Xcode 26 และ 27

## ก่อนเริ่ม { #setup }

1. ทำ[ลงมือปฏิบัติ](index.md#hands-on) ข้อ 2 **สรุปโน้ต** บน on-device ให้เสร็จก่อน
2. เพิ่ม package ให้ app
    1. File ▸ **Add Package Dependencies…**
    2. วาง URL นี้ในช่องค้นหา

        ```text
        https://github.com/swiftcodingclubth/yidh26-ai
        ```

    3. ตั้ง **Dependency Rule** เป็น **Exact Version** แล้วใส่ `0.0.2`
    4. กด **Add Package** แล้วติ๊ก **HackathonAI** ให้ target ของ app

3. สร้างไฟล์ `AICluster.swift` ใส่ address, API key ของทีม และ model ที่จะใช้

    ```swift
    import HackathonAI

    let aiCluster = HackathonAI(baseURL: "http://10.1.117.186:3949", apiKey: "API key ของทีม")

    extension HackathonAI {
        static let smartRoute: ModelID = "@route/sccth-gq"
    }
    ```

    `smartRoute` คือ model ID ของ Smart Route ที่ผู้จัดเตรียมไว้ ให้ใช้ตัวนี้แทน `.chat` ที่มากับ package

4. เพิ่ม key ใน Info.plist ตาม [Setup ข้อ 3](hackathon-ai.md#setup) เพื่อให้ app ต่อ server ใน local network ได้ ครั้งแรกที่ run ให้กด **Allow** เมื่อ iPad ถาม
5. เช็กว่า iPad ต่อ Wi-Fi ของงานอยู่

## โค้ดเดิม: on-device { #before }

```swift
func summarize(_ note: Note, creative: Bool) async throws {
    let session = LanguageModelSession(instructions: """
        You summarize a student's study notes. \
        Reply with exactly two sentences, in the same language as the note. \
        Only use facts that appear in the note.
        """)

    isWorking = true
    defer { isWorking = false }

    let options = GenerationOptions(
        temperature: creative ? 1.0 : 0.2,
        maximumResponseTokens: 120
    )
    let response = try await session.respond(
        to: "Title: \(note.title)\n\n\(note.body)",
        options: options)
    note.summary = response.content
}
```

## โค้ดใหม่: AI cluster { #after }

เพิ่ม `import HackathonAI` บนสุดของ `NoteAssistant.swift` แล้วแก้ `summarize` เป็นแบบนี้

```swift
func summarize(_ note: Note, creative: Bool) async throws {
    let instructions = """
        You summarize a student's study notes. \
        Reply with exactly two sentences, in the same language as the note. \
        Only use facts that appear in the note.
        """

    isWorking = true
    defer { isWorking = false }

    let prompt = "Title: \(note.title)\n\n\(note.body)"

    #if compiler(>=6.4)                // Xcode 27 เท่านั้น
    if #available(iOS 27, *) {         // iPad ต้องเป็น iOS 27
        let session = LanguageModelSession(
            model: aiCluster.languageModel(HackathonAI.smartRoute),   // เปลี่ยนเป็น model ของ AI cluster
            instructions: instructions)

        let options = GenerationOptions(
            temperature: creative ? 1.0 : 0.2,
            maximumResponseTokens: 120
        )
        let response = try await session.respond(to: prompt, options: options)
        note.summary = response.content
        return                         // จบตรงนี้ ไม่ต้องทำโค้ด Xcode 26 ข้างล่าง
    }
    #endif

    // Xcode 26 / iOS 26: ส่ง model ของงานเข้า LanguageModelSession ไม่ได้
    // จึงเรียก AI cluster ตรงๆ ซึ่งคืนค่าเป็น String จึงไม่ต้องใช้ .content
    note.summary = try await aiCluster.respond(
        to: prompt,
        model: HackathonAI.smartRoute,
        instructions: instructions,
        options: HackathonAI.Options(
            temperature: creative ? 1.0 : 0.2,
            maximumResponseTokens: 120))
}
```

สิ่งที่เปลี่ยน

- ย้าย instructions และ prompt ออกมาเป็นตัวแปร เพราะใช้ทั้ง 2 ทาง
- {{ mac.apple }} · Xcode 27: โค้ดเหมือนเดิมทุกอย่าง ต่างกันแค่ส่ง `aiCluster.languageModel(HackathonAI.smartRoute)` เข้า `LanguageModelSession`
- {{ mac.intel }} · Xcode 26: ใช้ `aiCluster.respond(...)` แทน session และใช้ `HackathonAI.Options` แทน `GenerationOptions`

## ลองดู { #try }

1. Run บน iPad กดปุ่ม **สรุป** ในโน้ตสักอัน แล้วเทียบกับผลจาก on-device
2. สลับ Precise / Creative แล้วสรุปอีกครั้ง
3. ปิด Wi-Fi แล้วกดสรุป ตอนนี้จะได้ error เพราะยังไม่มี fallback

## ลองต่อ { #extra }

- ใส่ [fallback](hackathon-ai.md#fallback) ให้กลับไปใช้ on-device เมื่อเรียก AI cluster ไม่ได้ และแสดงป้าย "AI cluster" หรือ "On-device" ว่าใครเป็นคนตอบ
- เปลี่ยนสร้าง study card ให้ใช้ AI cluster ด้วย `aiCluster.respond(to:generating:model:)` และ `@Generable` struct เดิม ดู[ตอบเป็น Swift struct](hackathon-ai.md#generable)

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

เพิ่ม `import HackathonAI` บนสุดของ `NoteAssistant.swift` แล้วแก้ `summarize` ตาม Xcode ที่ใช้

### {{ mac.apple }} · Xcode 27 { #xcode-27 }

ใช้ `LanguageModelSession` เหมือนเดิม ต่างกันแค่ส่ง `aiCluster.languageModel(HackathonAI.smartRoute)` เข้าไปเป็น model

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
        return
    }
    #endif

    // iPad ที่ยังเป็น iOS 26 หรือเพื่อนในทีมที่ใช้ Xcode 26 จะมาทำตรงนี้แทน
    note.summary = try await aiCluster.respond(
        to: prompt,
        model: HackathonAI.smartRoute,
        instructions: instructions,
        options: HackathonAI.Options(
            temperature: creative ? 1.0 : 0.2,
            maximumResponseTokens: 120))
}
```

ต้องมีโค้ดส่วนล่างไว้ด้วย เพราะ deployment target ของ project คือ iOS 26 และเพื่อนในทีมอาจใช้ Xcode 26 ดู[ใช้ project เดียวกันทั้ง Xcode 26 และ 27](../getting-started.md#project-xcode-26-27)

### {{ mac.intel }} · Xcode 26 { #xcode-26 }

iOS 26 SDK ส่ง model ของ AI cluster เข้า `LanguageModelSession` ไม่ได้ จึงเรียก `aiCluster.respond(...)` ตรงๆ แทน

```swift
func summarize(_ note: Note, creative: Bool) async throws {
    isWorking = true
    defer { isWorking = false }

    note.summary = try await aiCluster.respond(
        to: "Title: \(note.title)\n\n\(note.body)",
        model: HackathonAI.smartRoute,
        instructions: """
            You summarize a student's study notes. \
            Reply with exactly two sentences, in the same language as the note. \
            Only use facts that appear in the note.
            """,
        options: HackathonAI.Options(
            temperature: creative ? 1.0 : 0.2,
            maximumResponseTokens: 120))
}
```

สิ่งที่เปลี่ยนจากโค้ดเดิม

- ไม่มี `LanguageModelSession` แล้ว ส่ง instructions เข้า `respond` ตรงๆ
- ใช้ `HackathonAI.Options` แทน `GenerationOptions`
- `respond` คืนค่าเป็น `String` จึงไม่ต้องใช้ `.content`

## ลองดู { #try }

1. Run บน iPad กดปุ่ม **สรุป** ในโน้ตสักอัน แล้วเทียบกับผลจาก on-device
2. สลับ Precise / Creative แล้วสรุปอีกครั้ง
3. ปิด Wi-Fi แล้วกดสรุป ตอนนี้จะได้ error เพราะยังไม่มี fallback

## ลองต่อ { #extra }

- ใส่ [fallback](hackathon-ai.md#fallback) ให้กลับไปใช้ on-device เมื่อเรียก AI cluster ไม่ได้ และแสดงป้าย "AI cluster" หรือ "On-device" ว่าใครเป็นคนตอบ
- เปลี่ยนสร้าง study card ให้ใช้ AI cluster ด้วย `aiCluster.respond(to:generating:model:)` และ `@Generable` struct เดิม ดู[ตอบเป็น Swift struct](hackathon-ai.md#generable)

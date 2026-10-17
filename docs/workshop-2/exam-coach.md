# แบบฝึกหัด: Exam coach

ต่อยอด app **StudyNotes** ด้วยข้อสอบที่ปรับความยากตามคำตอบ ตอบถูกข้อต่อไปจะยากขึ้น ตอบผิดจะง่ายลง แล้วสรุปท้ายว่าเรื่องไหนเข้าใจแล้วและเรื่องไหนควรทบทวน คล้าย study notebooks ใน Gemini ที่ทำแบบทดสอบจากเอกสารแล้วบอกจุดที่ต้องทบทวน

งานนี้ต้องใช้ model ที่ใหญ่กว่า on-device เพราะต้องตรวจคำตอบแบบเขียนเองและตั้งคำถามระดับวิเคราะห์ เราจึงใช้ [AI cluster](hackathon-ai.md) และถอยกลับไปใช้ on-device เมื่อเรียกไม่ได้

ใช้ได้ทั้ง Xcode 26 และ 27

## สิ่งที่จะได้ { #goal }

- ปุ่ม **Exam coach** ในหน้า note ที่เปิดข้อสอบ 5 ข้อจาก note นั้น แนบไฟล์ PDF หรือ text เพิ่มได้
- ระดับความยาก 1 ถึง 5 ที่ขยับตามคำตอบ
- ตรวจคำตอบพร้อมคะแนน, feedback และคำตอบตัวอย่าง
- สรุปท้ายแบบทดสอบ: จุดแข็ง, เรื่องที่ควรทบทวน และสิ่งที่ควรทำต่อ
- ป้ายบอกว่า **AI cluster** หรือ **On-device** เป็นคนตอบ

## ก่อนเริ่ม { #setup }

1. เปิด project StudyNotes ซึ่งมี package `HackathonAI` อยู่แล้ว
2. เปิด `AICluster.swift` แล้วใส่ address และ API key ที่ได้รับ

    ```swift
    let aiCluster = HackathonAI(baseURL: "http://[TBC]:[TBC]", apiKey: "[TBC]")
    ```

3. เช็กว่าต่อ Wi-Fi ของงานอยู่

## ขั้นที่ 1: กำหนดรูปแบบคำตอบ { #step-1 }

ใน `ExamCoach.swift` สร้าง `@Generable` struct 3 ตัว ตัวแรกคือคำถาม ตัวที่สองคือผลตรวจ ตัวที่สามคือสรุปท้าย `@Guide` บอก model ว่าแต่ละช่องควรเป็นอะไร

```swift
@Generable
struct ExamQuestion {
    @Guide(description: "The specific sub-topic this question tests, 1 to 3 words, e.g. Calvin cycle. Not the note title.")
    var topic: String
    @Guide(description: "One clear question the student can answer in one or two sentences")
    var question: String
    @Guide(description: "A short hint that nudges the student without giving the answer away")
    var hint: String
}

@Generable
struct AnswerGrade {
    @Guide(description: "true if the answer is mostly correct")
    var isCorrect: Bool
    @Guide(description: "Score for the answer", .range(0...10))
    var score: Int
    @Guide(description: "One or two encouraging sentences: what was right, and what was missing or wrong")
    var feedback: String
    @Guide(description: "A correct answer in one or two sentences")
    var modelAnswer: String
}

@Generable
struct ExamReport {
    @Guide(description: "Topics the student answered well", .maximumCount(3))
    var strengths: [String]
    @Guide(description: "Topics the student should review", .maximumCount(3))
    var focusAreas: [String]
    @Guide(description: "One concrete thing to study next")
    var nextStep: String
}
```

## ขั้นที่ 2: เรียก AI cluster พร้อม fallback { #step-2 }

ทุกขั้นต่อจากนี้เรียกผ่านฟังก์ชันเดียว ลองเรียก AI cluster ก่อน ถ้าไม่สำเร็จให้ใช้ on-device model ด้วย `@Generable` struct ตัวเดียวกัน

```swift
private func generate<Content: Generable>(_ prompt: String, as type: Content.Type) async throws -> Content {
    do {
        let content = try await aiCluster.respond(to: prompt, generating: type, instructions: Self.instructions)
        answeredBy = "AI cluster"
        return content
    } catch {
        let session = LanguageModelSession(instructions: Self.instructions)
        let content = try await session.respond(to: prompt, generating: type).content
        answeredBy = "On-device"
        return content
    }
}
```

## ขั้นที่ 3: ตั้งคำถามตามระดับ { #step-3 }

อธิบายแต่ละระดับให้ model รู้ว่า "ยากขึ้น" หมายถึงอะไร แล้วส่งคำถามที่ถามไปแล้วไปด้วย model จะได้ไม่ถามซ้ำ

```swift
static let levels: [Int: String] = [
    1: "Recall: ask for one fact stated in the notes.",
    2: "Understand: ask the student to explain an idea in their own words.",
    3: "Apply: ask the student to use an idea on a new, concrete example.",
    4: "Analyze: ask the student to compare ideas or explain why something happens.",
    5: "Create: ask the student to combine several ideas to solve an unfamiliar problem.",
]

func nextQuestion() async {
    let asked = rounds.map { "- \($0.question.question)" }.joined(separator: "\n")
    let prompt = """
        Study material:
        \(material)

        Write one exam question at level \(level) of 5.
        \(Self.levels[level]!)
        Don't repeat these questions:
        \(asked.isEmpty ? "(none yet)" : asked)
        """
    question = await run { try await self.generate(prompt, as: ExamQuestion.self) }
}
```

## ขั้นที่ 4: ตรวจคำตอบแล้วปรับระดับ { #step-4 }

ส่งเนื้อหา, คำถาม และคำตอบของนักเรียนให้ model ตรวจ แล้วใช้ `isCorrect` ขยับระดับของข้อถัดไป

```swift
func submit(answer: String) async {
    guard let question else { return }
    let prompt = """
        Study material:
        \(material)

        Question (level \(level) of 5): \(question.question)
        Student's answer: \(answer)

        Grade the answer against the study material.
        If the student says they don't know, or the answer is empty or off-topic, \
        set isCorrect to false and score to 0.
        """
    guard let grade = await run({ try await self.generate(prompt, as: AnswerGrade.self) }) else { return }

    rounds.append(Round(level: level, question: question, answer: answer, grade: grade))
    lastGrade = grade
    level = grade.isCorrect ? min(level + 1, 5) : max(level - 1, 1)   // ถูกแล้วยากขึ้น ผิดแล้วง่ายลง

    if isFinished {
        await makeReport()
    }
}
```

## ขั้นที่ 5: แนบไฟล์ { #step-5 }

ให้นักเรียนแนบ PDF หรือไฟล์ text เพิ่มจาก note ได้ ใช้ `.fileImporter` เลือกไฟล์ แล้วอ่านข้อความด้วย PDFKit ข้อความจากไฟล์จะต่อท้ายเนื้อหาของ note

```swift
static func readText(from url: URL) throws -> String {
    let canAccess = url.startAccessingSecurityScopedResource()
    defer { if canAccess { url.stopAccessingSecurityScopedResource() } }

    let text: String
    if url.pathExtension.lowercased() == "pdf" {
        text = PDFDocument(url: url)?.string ?? ""
    } else {
        text = try String(contentsOf: url, encoding: .utf8)
    }
    return String(text.prefix(20_000))   // คุมขนาด prompt
}
```

!!! tip "ทำไมต้องใช้ AI cluster"
    Note กับไฟล์แนบรวมกันยาวเกิน context ของ on-device model ได้ง่าย และการตรวจคำตอบที่เขียนเองต้องใช้ model ที่ใหญ่พอ ลองปิด Wi-Fi แล้วทำข้อสอบอีกครั้งเพื่อเทียบคุณภาพคำถามและการตรวจกับ on-device

## ลองต่อ { #extra }

- ส่งคำตอบผิดของข้อที่แล้วไปใน prompt ด้วย ให้ข้อถัดไปถามเรื่องเดิมจากอีกมุมหนึ่ง
- {{ mac.apple }} ใช้ `LanguageModelSession(model: aiCluster.languageModel(.chat))` session เดียวตลอดข้อสอบ model จะจำคำถามและคำตอบเองโดยไม่ต้องส่ง `asked` ไป ดู[ใช้ model ของงานใน session](hackathon-ai.md#model-session)
- ใช้ `.reasoning` ตรวจคำตอบระดับ 4 ถึง 5 ซึ่งต้องคิดหลายขั้น

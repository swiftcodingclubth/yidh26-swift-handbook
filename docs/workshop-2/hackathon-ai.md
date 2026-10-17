# AI cluster

ในงานมี AI cluster ซึ่งเป็นกลุ่ม Mac ที่ run open-source model ไว้ให้ทุกทีมใช้ฟรีผ่าน Wi-Fi ของงาน เรียกผ่าน package **HackathonAI** ซึ่งจัดการ HTTP request, API key และการแปลง JSON ให้ทั้งหมด ใช้ได้ทั้ง Xcode 26 และ 27

!!! note "หน้านี้คือ reference"
    หน้านี้รวมวิธีเรียก AI cluster ทั้งหมดไว้ใช้ตอน hackathon ส่วนแบบฝึกหัดในคลาสอยู่ที่ [สรุปโน้ตด้วย AI cluster](summarize-ai-cluster.md)

## การเชื่อมต่อ { #connection }

| รายการ | ค่า |
|---|---|
| Address | `http://10.1.117.186:3949` ใช้ได้เฉพาะใน Wi-Fi ของงาน |
| API key | แจกให้แต่ละทีมภายหลัง |
| Swift package | `https://github.com/swiftcodingclubth/yidh26-ai` เวอร์ชัน `0.0.2` (library `HackathonAI`) |
| Rate limit ต่อทีม | [TBC] |

ทุก model เรียกผ่าน address เดียวกัน cluster จะส่ง request ไปยังเครื่องที่ run model นั้นให้เอง

## Model ที่ใช้ได้ { #models }

!!! warning "ใช้ `HackathonAI.smartRoute` แทน `.chat`"
    Smart Route ของงานใช้ model ID `@route/sccth-gq` ซึ่งไม่ตรงกับ `.chat` ที่มากับ package ให้ประกาศ `HackathonAI.smartRoute` ตาม [Setup ข้อ 2](#setup) แล้วส่งเข้า `model:` ทุกครั้ง Model อื่นในตารางยังเป็น TBC เรียก `models()` เพื่อดูรายชื่อที่ cluster มีอยู่จริง

| ใน package | Model | ทำอะไรได้ | เหมาะกับ |
|---|---|---|---|
| `HackathonAI.smartRoute` | **Smart Route** (Gemma 4 26B / Qwen3.6 35B) | ข้อความ, `@Generable`, tool calling | ตัวเริ่มต้น: สรุป, ถาม-ตอบ, ภาษาไทย, ตอบเป็น struct Server เลือก model ให้เองตามคำถาม |
| `.reasoning` | **Qwen3.8 27B** | ข้อความ, รูป, `@Generable`, tool calling, คิดก่อนตอบ | โจทย์ที่ต้องคิดหลายขั้น, วิเคราะห์เอกสาร, อ่านรูปหรือกราฟ ช้ากว่า Smart Route |
| `.medical` | **MedGemma 1.5 4B** | ข้อความ | ศัพท์และความรู้ทางการแพทย์ ใช้ synthetic data เท่านั้น |
| `.ocr` | **Typhoon OCR 1.5 2B** | รูป → ข้อความ | อ่านข้อความภาษาไทยและอังกฤษจากรูปเอกสาร, ป้าย, กระดาน |
| `.tts` | **Qwen3-TTS 1.7B** | ข้อความ → เสียง | อ่านข้อความออกเสียง |
| `.asr` | **Qwen3-ASR 1.7B** | เสียง → ข้อความ (ไทย/อังกฤษ) | ถอดเสียงพูด ถ้าต้องใช้แบบ offline ให้ใช้ Whisper ผ่าน [Core AI](../workshop-3/core-ai.md) บน device แทน |

Smart Route และ `.reasoning` แต่ละตัว run บนหลายเครื่อง Smart Route กระจายงานไปที่ 3 เครื่อง ส่วน Qwen3.8 run แยกกัน 4 เครื่องสำหรับทีมที่ต้องใช้ reasoning หนักๆ

## Setup { #setup }

1. เพิ่ม package ให้ app
    1. File ▸ **Add Package Dependencies…**
    2. วาง URL นี้ในช่องค้นหา

        ```text
        https://github.com/swiftcodingclubth/yidh26-ai
        ```

    3. ตั้ง **Dependency Rule** เป็น **Exact Version** แล้วใส่ `0.0.2`
    4. กด **Add Package** แล้วติ๊ก **HackathonAI** ให้ target ของ app

    !!! note "ทำไมต้อง Exact Version"
        ทุกทีมจะใช้โค้ดชุดเดียวกัน และ package จะไม่เปลี่ยนเองระหว่างงาน ถ้าผู้จัดประกาศเวอร์ชันใหม่ ให้ไปที่ project ▸ แท็บ **Package Dependencies** ▸ ดับเบิลคลิก `yidh26-ai` แล้วเปลี่ยนเลขเวอร์ชัน
2. สร้างไฟล์ `AICluster.swift` แล้วใส่ address, API key และ model ID ของ Smart Route เรียก `aiCluster` และ `HackathonAI.smartRoute` ได้จากทุกที่ใน app

    ```swift
    import HackathonAI

    let aiCluster = HackathonAI(baseURL: "http://10.1.117.186:3949", apiKey: "team-XX-xxxx")

    extension HackathonAI {
        static let smartRoute: ModelID = "@route/sccth-gq"
    }
    ```

3. เพิ่ม key ใน Info.plist เพื่อให้ app เชื่อมต่อ server ใน local network ได้ ครั้งแรกที่ run ให้กด **Allow** เมื่อ iPad ถาม

    ```text
    NSLocalNetworkUsageDescription
        "Connects to the AI cluster on the event network."
    NSAppTransportSecurity
        NSAllowsArbitraryLoads = YES
    ```

    AI cluster ใช้ `http://` กับ IP address ตรงๆ ถ้าไม่ใส่ `NSAllowsArbitraryLoads` iOS จะ block การเชื่อมต่อ **อย่าใส่ `NSAllowsLocalNetworking` คู่กัน** เพราะ iOS จะไม่สนใจ `NSAllowsArbitraryLoads` ทันที และ package จะแจ้ง error `.blockedByAppTransportSecurity`

!!! danger "อย่า push API key ขึ้น GitHub แบบ public"
    ถ้า repo ของทีมเป็น public คนอื่นจะเอา key ไปใช้ quota ของทีมได้ ตั้ง repo เป็น private หรือเพิ่ม `AICluster.swift` ลง `.gitignore`

## ถามแล้วได้คำตอบ { #respond }

```swift
// รอคำตอบเต็ม
let answer = try await aiCluster.respond(
    to: "สรุปเรื่องนี้ใน 3 ประโยค: \(text)",
    model: HackathonAI.smartRoute,
    instructions: "ตอบเป็นภาษาไทย สั้นและชัด")

// Streaming: แต่ละรอบได้คำตอบทั้งหมดจนถึงตอนนั้น ใส่ให้ UI ได้เลย
for try await partial in aiCluster.streamResponse(to: prompt, model: .reasoning) {
    output = partial
}
```

ตั้งค่าเพิ่มได้ผ่าน `options` เช่น `options: .init(temperature: 0.2, maximumResponseTokens: 300)`

## ตอบเป็น Swift struct ด้วย `@Generable` { #generable }

ใช้ `@Generable` struct แบบเดียวกับที่ใช้กับ `LanguageModelSession` ได้เลย package จะส่ง schema ไปให้ model แล้วแปลง JSON ที่ได้กลับมาเป็น struct ให้

```swift
@Generable
struct StudyCard {
    @Guide(description: "A short title")
    var title: String
    @Guide(description: "Key points", .count(3))
    var keyPoints: [String]
}

let card = try await aiCluster.respond(to: note.body, generating: StudyCard.self, model: HackathonAI.smartRoute)
```

!!! question "`@Generable` เรียก API ข้างนอกได้ไหม"
    ได้ `@Generable` แค่บอกว่าคำตอบต้องหน้าตาเป็นอย่างไร (schema) ส่วนใครเป็นคนตอบนั้นแยกกัน ใช้ struct เดียวกันกับ on-device model, `aiCluster.respond(generating:)` หรือ session ที่ใช้ model ของงาน (iOS 27) ก็ได้ ใช้ได้ตั้งแต่ iOS 26

## ส่งรูป, อ่านข้อความในรูป, เสียง { #media }

```swift
// ถามเกี่ยวกับรูป (ใช้ model ที่รับรูปได้)
let explanation = try await aiCluster.respond(
    to: "กราฟนี้บอกอะไร", model: .reasoning, images: [cgImage])

// อ่านข้อความจากรูปด้วย Typhoon OCR
let text = try await aiCluster.recognizeText(in: cgImage)

// ข้อความ → เสียง แล้วเล่นด้วย AVAudioPlayer
let audio = try await aiCluster.speak("สวัสดีครับ")
player = try AVAudioPlayer(data: audio)
player?.play()

// เสียง → ข้อความ
let transcript = try await aiCluster.transcribe(try Data(contentsOf: recordingURL), language: "th")
```

## ใช้ model ของงานใน `LanguageModelSession` { #model-session }

!!! mchip "{{ mac.apple }} · Xcode 27"
    iOS 27 ส่ง model ของงานเข้า `LanguageModelSession` ได้โดยตรง session จะจำบทสนทนา, ใช้ tool calling ได้เหมือน on-device model ครอบโค้ดด้วย `#if compiler(>=6.4)` ตาม[วิธีในหน้าเริ่มต้นใช้งาน](../getting-started.md#project-xcode-26-27) เพื่อให้เพื่อนที่ใช้ Xcode 26 ยัง build ได้

```swift
#if compiler(>=6.4)
let session = LanguageModelSession(
    model: aiCluster.languageModel(HackathonAI.smartRoute),
    tools: [FindNotesTool()],
    instructions: Instructions("ตอบเป็นภาษาไทย"))
let reply = try await session.respond(to: "สรุป note เรื่องสังเคราะห์แสง")

// ส่งรูปได้ถ้าบอกว่า model รับรูปได้
let vision = aiCluster.languageModel(.reasoning, supportsVision: true)
#endif
```

!!! intel "{{ mac.intel }} · Xcode 26"
    ใช้ `aiCluster.respond(...)` และ `streamResponse(...)` แทน session ได้ครบ รวมถึง `@Generable` ถ้าต้องการบทสนทนาหลายรอบ ส่ง array ของ message เอง: `aiCluster.respond(to: [.system("..."), .user("..."), .assistant("..."), .user("...")])`

## Fallback เมื่อใช้ AI cluster ไม่ได้ { #fallback }

เรียก AI cluster ไม่สำเร็จได้หลายแบบ เช่น ออกนอก Wi-Fi ของงาน, cluster มีคิวยาว หรือทีมเรียกเกิน rate limit ให้ถอยกลับไปใช้ on-device model เพื่อให้ app ยังทำงานได้ และบอกใน UI ว่าใครเป็นคนตอบ

```swift
func summarize(_ text: String) async throws -> (summary: String, answeredBy: String) {
    do {
        return (try await aiCluster.respond(to: "สรุป: \(text)", model: HackathonAI.smartRoute), "AI cluster")
    } catch {
        let reply = try await LanguageModelSession().respond(to: "สรุป: \(text)")
        return (reply.content, "On-device")
    }
}
```

Error ที่เจอได้เป็น `HackathonAIError` แยกกรณีได้ถ้าต้องการบอกผู้ใช้ให้ชัด

| Error | ความหมาย |
|---|---|
| `.unreachable` | ไม่ได้อยู่ใน Wi-Fi ของงาน หรือ cluster ล่ม |
| `.blockedByAppTransportSecurity` | ยังไม่ได้ใส่ `NSAllowsArbitraryLoads` ใน Info.plist |
| `.unauthorized` | API key ผิด |
| `.rateLimited(retryAfter:)` | เรียกถี่เกินไป รอตามเวลาที่บอกแล้วค่อยลองใหม่ |
| `.modelNotFound` | ไม่มี model ชื่อนี้ เรียก `models()` ดูชื่อที่มี |

ถ้าต้องการซ่อน feature ที่ต้องใช้ AI cluster ตอนอยู่นอกงาน เช็กก่อนด้วย `await aiCluster.isReachable()`

## Production habits { #habits }

!!! warning "แบ่งกันใช้"
    ทุกทีมใช้ AI cluster ชุดเดียวกัน และแต่ละทีมมี rate limit

    - อย่าเรียก model ใน loop หรือทุกครั้งที่ผู้ใช้พิมพ์ ให้เรียกเมื่อกดปุ่มหรือพิมพ์เสร็จ
    - จำกัดความยาวคำตอบด้วย `maximumResponseTokens` เท่าที่จำเป็น
    - ใช้ Smart Route เป็นหลัก ใช้ `.reasoning` เฉพาะงานที่ต้องคิดจริงๆ เพราะช้ากว่าและมีเครื่องน้อยกว่า
    - ถ้าโดน rate limit อย่ากดซ้ำทันที รอสักครู่หรือใช้ fallback

!!! danger "ข้อมูลสุขภาพ"
    - ใช้ **synthetic data เท่านั้น** ห้ามใช้ข้อมูลผู้ป่วยจริง เพราะข้อมูลสุขภาพเป็นข้อมูลอ่อนไหวตาม PDPA
    - ผลจาก `.medical` เป็นข้อมูลเบื้องต้น **ไม่ใช่การวินิจฉัยหรือคำแนะนำการรักษา** และต้องบอกผู้ใช้ชัดเจนใน UI

!!! tip "Demo ที่ไม่พัง"
    Judging ต้อง demo ใน Wi-Fi ของงาน แต่ network อาจมีปัญหาได้เสมอ ให้มี on-device fallback ไว้ ลองปิด Wi-Fi แล้ว run ดูก่อน demo

# Dynamic Profile

!!! mchip "{{ mac.apple }} · Xcode 27"
    Dynamic Profile เป็น API ใหม่ของ iOS 27 ใช้ได้เฉพาะ Xcode 27

ใน app จริง model มักต้องทำตัวต่างกันตามสถานการณ์ เช่น ผู้ช่วยติวที่ตอนแรก **อธิบาย** เนื้อหา แล้วพอผู้ใช้พร้อมก็เปลี่ยนเป็น **ถาม quiz** ถ้าใช้ `LanguageModelSession(instructions:)` แบบเดิม instructions, tools และ model ถูกกำหนดตอนสร้าง session และเปลี่ยนทีหลังไม่ได้ ต้องสร้าง session ใหม่แล้วย้ายบทสนทนาเดิมไปเอง

| API | ทำอะไร |
|---|---|
| [`DynamicInstructions`](#dynamic-instructions) | รวม instructions และ tools ที่ model ต้องใช้ ณ ตอนนั้น คำนวณใหม่ก่อนส่ง request ทุกครั้ง |
| [`Profile`](#profiles) | ผูก instructions เข้ากับการตั้งค่าระดับ session เช่น ใช้ model ตัวไหน และ reasoning level |
| [`DynamicProfile`](#dynamic-profiles) | เลือก profile ที่ active ทีละหนึ่งตัว และสลับ profile ให้เมื่อ state เปลี่ยน |

## Dynamic instructions { #dynamic-instructions }

`DynamicInstructions` ใส่ `Instructions` และ `tools` ที่ model ต้องใช้ในแต่ละสถานการณ์ Framework จะ evaluate `body` ใหม่ก่อนส่ง request ให้ model ทุกครั้ง จึงใส่เงื่อนไขตาม state ของ app ได้ เช่น ใส่ tool บางตัวเฉพาะตอนที่จำเป็นต้องใช้

```swift
import FoundationModels

enum TutorMode {
    case explain, quiz
}

@Observable
final class TutorState {
    var mode: TutorMode = .explain
    var hasNotes = false
}

struct Explainer: DynamicInstructions {
    var state: TutorState

    var body: some DynamicInstructions {
        Instructions("อธิบายเนื้อหาเป็นภาษาไทยแบบเข้าใจง่าย ยกตัวอย่างประกอบ")
        // ใส่ tool ค้นโน้ตเฉพาะเมื่อผู้ใช้มีโน้ตแล้ว
        if state.hasNotes {
            SearchNotesTool()
        }
    }
}
```

## Profiles { #profiles }

`Profile` สร้าง dynamic instructions แล้วใช้ modifier ตั้งค่าระดับ session เช่น ใช้ model ตัวไหน และให้ model คิดก่อนตอบมากแค่ไหน

```swift
Profile {
    Explainer(state: state)
}
.model(OnPremLanguageModel(.thai, teamKey: Secrets.teamKey))
.temperature(0.7)
```

| Modifier | ใช้ทำอะไร |
|---|---|
| `.model(_:)` | เลือก model ของ profile นี้ เช่น on-device, PCC หรือ model บน cluster |
| `.reasoningLevel(_:)` | ให้ model คิดก่อนตอบมากหรือน้อย: `.light`, `.moderate`, `.deep` (สำหรับ model บน server ที่รองรับ) |
| `.temperature(_:)` | ค่ายิ่งสูงคำตอบยิ่งหลากหลาย ค่าต่ำได้คำตอบคงที่กว่า |
| `.maximumResponseTokens(_:)` | จำกัดความยาวคำตอบ |
| `.toolCallingMode(_:)` | `.allowed` ให้ model เลือกเอง, `.required` ต้องเรียก tool, `.disallowed` ห้ามเรียก |

## Dynamic profiles { #dynamic-profiles }

`LanguageModelSession.DynamicProfile` รวมหลาย profile ไว้ด้วยกัน ใน `body` ใช้ `switch` หรือ `if` เลือกว่าตอนนี้จำเป็นต้องใช้ profile อันไหน Framework จะ evaluate `body` ใหม่ทุกครั้งก่อนส่ง prompt พอ state เปลี่ยน session จะสลับ profile ให้เองตามเงื่อนไขที่กำหนดไว้

```swift
struct TutorProfile: LanguageModelSession.DynamicProfile {
    var state: TutorState

    var body: some DynamicProfile {
        switch state.mode {
        case .explain:
            Profile { Explainer(state: state) }
                .model(OnPremLanguageModel(.thai, teamKey: Secrets.teamKey))
                .temperature(0.7)
        case .quiz:
            Profile { Instructions("ถามคำถามทีละข้อจากเนื้อหาที่คุยกันมา แล้วรอให้ผู้ใช้ตอบ") }
                .model(SystemLanguageModel.default)
                .temperature(0.2)
        }
    }
}
```

สร้าง session ด้วย `LanguageModelSession(profile:)` แล้วเปลี่ยน state จากโค้ดใน app เช่น เมื่อผู้ใช้กดปุ่ม "เริ่ม quiz" session จะใช้ profile quiz ในการตอบครั้งถัดไป และ model ยังจำได้ว่าอธิบายอะไรไปแล้ว จึงถามจากเนื้อหานั้นได้

```swift
let state = TutorState()
let session = LanguageModelSession(profile: TutorProfile(state: state))
try await session.respond(to: "อธิบาย optional ใน Swift")   // profile explain บน cluster

state.mode = .quiz                        // เช่น ตอนกดปุ่ม "เริ่ม quiz"
try await session.respond(to: "เริ่มเลย")   // profile quiz บน device
```

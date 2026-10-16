# Core AI

!!! mchip "{{ mac.apple }} · Xcode 27"
    Core AI เป็น framework ใหม่ของ iOS 27 ใช้ได้เฉพาะ Xcode 27 ครอบโค้ดด้วย `#if compiler(>=6.4)` และ `#if canImport(CoreAILanguageModels)` ตาม[วิธีในหน้าเริ่มต้นใช้งาน](../getting-started.md#project-xcode-26-27) เพื่อให้เพื่อนที่ใช้ Xcode 26 ยัง build project ได้

**Core AI** คือ framework ของ Apple สำหรับ run model ขนาดใหญ่บนเครื่อง เช่น open-source language model, model สร้างภาพ และ model แยกวัตถุในภาพ ทุกอย่าง run บน iPad ไม่ต้องใช้ internet ข้อมูลไม่ออกจากเครื่อง

## ต่างจาก Foundation Models และ Core ML อย่างไร

| | Foundation Models | Core ML | Core AI |
|---|---|---|---|
| Model | AFM 3 ของ Apple ที่มีในเครื่องอยู่แล้ว | Model เล็กที่ train เอง เช่น จาก Create ML | Open-source model ที่เลือกเอง เช่น Qwen, Gemma, Whisper |
| ต้องใส่ model ใน app | ไม่ต้อง | ใส่ไฟล์เล็ก ๆ | ใส่ไฟล์ใหญ่ หลายร้อย MB ขึ้นไป |
| ใช้เมื่อ | งานภาษาทั่วไป | จดจำท่าทาง เสียง ภาพแบบที่กำหนดเอง | ต้องการ model เฉพาะที่ AFM ไม่มี หรืออยากเลือก model เอง |

จุดสำคัญคือ language model ของ Core AI **ใช้กับ `LanguageModelSession` ได้เหมือน AFM** ทุกอย่างที่เรียนใน Workshop 2 ทั้ง [Foundation Models](../workshop-2/foundation-models.md), [Tool calling](../workshop-2/tool-calling.md) และ [Dynamic Profile](../workshop-2/dynamic-profiles.md) จึงใช้กับ Core AI ได้ทันที

## Model สำเร็จรูปจาก Apple

Apple มี repo [`apple/coreai-models`](https://github.com/apple/coreai-models) ที่รวม model ยอดนิยมซึ่งแปลงเป็นรูปแบบของ Core AI แล้ว พร้อม Swift package สำหรับใช้ใน app

ในงานนี้ใช้ **Qwen3 0.6B** ซึ่งเป็น language model ขนาดเล็กที่ run บน iPad ได้ Model ถูก export ไว้ให้แล้ว **รับจาก TA** (ไฟล์ใหญ่ประมาณ 430 MB ดาวน์โหลดผ่าน Wi-Fi ของงานพร้อมกันไม่ไหว) ได้เป็น folder แบบนี้

```text
qwen3_0_6b_mixed_4bit_8bit_static/
├── metadata.json          ← ข้อมูลของ model
├── tokenizer/             ← ตัวแปลงข้อความเป็น token ต้องมีเสมอ
└── qwen3_0_6b_mixed_4bit_8bit_static.aimodel
```

## Setup

### 1. เพิ่ม Swift package

**File › Add Package Dependencies…** วาง URL

```text
https://github.com/apple/coreai-models.git
```

เลือก product **`CoreAILM`** แล้วเพิ่มเข้า target ของ app

### 2. ใส่ model ใน app

ลาก **ทั้ง folder** ของ model เข้า Xcode project เลือก **Create folder references** (folder สีฟ้า) และติ๊ก target ของ app ต้องใส่ทั้ง folder เพราะ Core AI ต้องใช้ `metadata.json` และ `tokenizer/` ที่อยู่คู่กับไฟล์ `.aimodel`

### 3. เพิ่ม memory limit

Language model ใช้ memory มาก iPadOS อาจปิด app ทิ้งถ้าใช้เกินขีดจำกัดปกติ เพิ่ม entitlement นี้ที่ **Signing & Capabilities › + Capability › Increased Memory Limit**

```text
com.apple.developer.kernel.increased-memory-limit = YES
```

!!! warning "ยังไม่ได้ทดสอบบน iPad ด้วย Personal Team"
    ขั้นตอนการใส่ model และ entitlement ข้างบนมาจากเอกสารของ Apple ถ้า build ไม่ผ่าน, Personal Team ไม่ยอมให้เพิ่ม capability หรือ app โหลด model ไม่เจอ ให้ถาม TA

## โหลดและใช้ model

สร้าง `CoreAILanguageModel` จาก folder ของ model แล้วส่งให้ `LanguageModelSession` เหมือนที่ทำกับ model บน cluster ใน Workshop 2

```swift
import FoundationModels
import CoreAILanguageModels

let folder = Bundle.main.url(
    forResource: "qwen3_0_6b_mixed_4bit_8bit_static", withExtension: nil)!

let model = try await CoreAILanguageModel(resourcesAt: folder)
let session = LanguageModelSession(model: model)

let response = try await session.respond(to: "อธิบาย LiDAR สั้น ๆ")
print(response.content)
```

- `resourcesAt` ต้องเป็น **folder** ที่มี `metadata.json` ไม่ใช่ไฟล์ `.aimodel`
- **ครั้งแรกจะช้า** เพราะ Core AI ปรับ model ให้เหมาะกับเครื่องแล้วเก็บ cache ไว้ ครั้งต่อไปจะเร็วขึ้น ให้แสดงข้อความ "กำลังเตรียม model…" ระหว่างรอ
- **โหลด model ครั้งเดียว** แล้วใช้ซ้ำทั้ง app ไม่ต้องสร้างใหม่ทุกครั้งที่ถาม
- Streaming ด้วย `streamResponse(to:)` และ `@Generable` ใช้ได้เหมือน AFM

## Mood Coach { #mood-coach }

ต่อยอดจาก[ลงมือปฏิบัติ](index.md#mood): ส่งข้อความที่ผู้ใช้พิมพ์ อารมณ์ที่ text classifier ทายได้ และความมั่นใจ ให้ Core AI เขียนข้อความให้กำลังใจสั้น ๆ ใช้ `@Generable` เพื่อให้ได้ผลเป็น struct นำไปแสดงใน UI ได้ทันที

```swift
@Generable
struct MoodTip {
    @Guide(description: "ข้อความให้กำลังใจหรือคำแนะนำสั้น ๆ 1 ประโยค")
    var message: String
    @Guide(description: "emoji 1 ตัวที่เข้ากับข้อความ")
    var emoji: String
}

let coach = LanguageModelSession(
    model: model,
    instructions: "You are a kind friend. Answer in Thai, very briefly.")

let result = try await coach.respond(
    to: "User wrote: \(text). Detected emotion: \(label), confidence \(Int(confidence * 100))%",
    generating: MoodTip.self
).content

print(result.emoji, result.message)
```

!!! tip "Model เล็ก ต้องช่วยมันหน่อย"
    Qwen3 0.6B เล็กกว่า AFM มาก ภาษาไทยอาจไม่ดีเท่า ให้เขียน instructions สั้นและชัด, ใช้ `@Generable` บังคับรูปแบบคำตอบ และเรียกเฉพาะเมื่อจำเป็น เช่น ตอนผู้ใช้กดบันทึก ไม่ใช่ทุกครั้งที่พิมพ์ ลองเทียบผลกับ [AFM 3 หรือ model บน cluster](../workshop-2/models.md) แล้วเลือกตัวที่เหมาะกับ app

## ใช้ร่วมกับ

- [Dynamic Profile](../workshop-2/dynamic-profiles.md#4-model): ส่ง Core AI model เข้า `.model()` ได้ เช่น ใช้ AFM ตอนคุยทั่วไป แล้วสลับไป Core AI model ที่เลือกเองตอนให้คำแนะนำ

## ไปต่อ

ส่วนนี้ไม่ได้ทำใน workshop แต่ใช้ต่อยอดในช่วง hackathon ได้

| หัวข้อ | สรุป |
|---|---|
| **ดู model ที่มี** | `uv run coreai.model.registry --list-models` ใน repo `coreai-models` มีทั้ง language model, speech-to-text, แยกวัตถุ และสร้างภาพ |
| **Export model เอง** | `uv run coreai.llm.export Qwen/Qwen3-0.6B --platform iOS --max-context-length 4096` แปลง model จาก Hugging Face เป็นรูปแบบ Core AI ใช้เวลาและพื้นที่มาก ทำบน {{ mac.apple }} |
| **Quantization** | Model สำหรับ iOS ถูกบีบอัดเป็น 4-bit แล้ว ไฟล์เล็กลงหลายเท่าและเร็วขึ้น แลกกับความแม่นที่ลดลงเล็กน้อย Apple แนะนำให้ model บน iOS มีขนาดไม่เกิน 2 GB |
| **ดู performance** | ใช้ Instruments ดูเวลาโหลด model และความเร็วในการสร้างคำตอบ |

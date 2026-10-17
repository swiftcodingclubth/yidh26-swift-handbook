# Bring intelligence to your app with Foundation Models and on-prem AI

Workshop นี้ทำให้ app ของทีมใช้ language model ได้ ทั้ง model ที่ run บน iPad, บน server ของ Apple และบน AI cluster ของงาน ด้วยโค้ดชุดเดียวกัน เหมาะกับ idea ที่ต้องใช้ภาษา เช่น สรุป แปล ตอบคำถาม หรือจัดข้อความให้เป็นข้อมูลที่มีโครงสร้าง

## สิ่งที่จะได้เรียน { #outcomes }

1. **เลือก model ให้เหมาะกับงาน**: เข้าใจว่าแต่ละที่ต่างกันอย่างไรในเรื่อง privacy, ความเร็ว, ความเก่ง, ภาษาไทย และการใช้งานนอกสถานที่
2. **ใช้ `LanguageModelSession`**: ถามแล้วได้คำตอบ, แสดงคำตอบทีละส่วน (streaming), ให้ model ตอบเป็น Swift struct (`@Generable`) และให้ model เรียกฟังก์ชันของเรา (tool calling)
3. **ใช้ model บน cluster**: สลับไปใช้ model ภาษาไทยหรือ model การแพทย์ผ่าน package **HackathonAI**
4. **รับมือเมื่อ model ใช้ไม่ได้**: เช็กว่า iPad มี Apple Intelligence ไหม และถ้า cluster ไม่ว่างหรือเชื่อมต่อไม่ได้ ให้ app ถอยกลับมาใช้ on-device model เองโดยไม่ crash

## แนวคิดหลัก { #concepts }

### ประเภทต่างๆของ Language model

- **On-device AFM 3**: Apple Foundation Models รุ่นที่ 3 run บน iPad เลย ฟรี ข้อมูลไม่ออกจากเครื่อง ตอบเร็ว และใช้ได้แม้ไม่มี internet แต่ model มีขนาดเล็ก เหมาะกับงานสั้นๆ ที่ไม่ซับซ้อน
- **Private Cloud Compute (PCC)**: AFM 3 ที่ run บน server ของ Apple เก่งกว่าบน device และ Apple ออกแบบให้ข้อมูลยังเป็นส่วนตัว แต่ต้องต่อ internet
- **AI cluster ของงาน**: Mac cluster ที่ผู้จัด run open-source model เฉพาะทางไว้ให้ เช่น model ภาษาไทยและ model การแพทย์ ใช้ได้เฉพาะใน Wi-Fi ของงาน

### เปลี่ยนประเภทของ Language model ได้ง่ายๆ

Language model ทั้ง 3 รูปแบบใช้ `LanguageModelSession` ของ Foundation Models framework เหมือนกัน ถ้าจะสลับ model ก็แค่เปลี่ยน model ที่ส่งให้ session ส่วน `respond(to:)`, streaming, `@Generable` และ tool calling ใช้โค้ดเดิมทั้งหมด

```swift
// On-device AFM 3
let onDevice = LanguageModelSession()

// Model ภาษาไทยบน cluster: ต่างกันแค่ model ที่ส่งเข้าไป
let thai = LanguageModelSession(
    model: OnPremLanguageModel(.thai, teamKey: Secrets.teamKey))

// เรียกใช้แบบเดียวกันทุก model
let a = try await onDevice.respond(to: "สรุปข้อความนี้: \(text)")
let b = try await thai.respond(to: "สรุปข้อความนี้: \(text)")
```

เริ่มจาก on-device ก่อนเสมอ แล้วค่อยส่งงานที่ยากหรือต้องการภาษาไทยที่ดีกว่าไปที่ PCC หรือ cluster ดูวิธีเลือกได้ที่ [เลือก model](models.md)

## MacBook แต่ละเครื่องทำอะไรได้บ้าง { #machines }

Feature บางอย่างต้องใช้ iOS 27 SDK ซึ่งมีเฉพาะใน Xcode 27 บน {{ mac.apple }}

!!! mchip "{{ mac.apple }} · Xcode 27"
    ทำได้ครบทุกส่วน: ใช้ on-device AFM 3, ส่ง model บน cluster เข้า `LanguageModelSession` ได้โดยตรง, ใช้ PCC และส่งรูปให้ AFM 3 วิเคราะห์

!!! intel "{{ mac.intel }} · Xcode 26"
    ใช้ `LanguageModelSession` กับ on-device AFM 3 ได้ตามปกติ แต่ iOS 26 SDK ยังส่ง model บน cluster เข้า session ไม่ได้ จึงต้องเรียก cluster ผ่าน [`OnPremClient`](hackathon-ai.md) แทน ซึ่งเป็น API แยกที่ใช้งานง่ายแต่ไม่มี `@Generable` และ tool calling

## หัวข้อหลัก { #pages }

อ่านตามลำดับนี้จะเข้าใจง่ายที่สุด

| หน้า | เนื้อหา |
|---|---|
| [เลือก model](models.md) | Model แต่ละตัว run ที่ไหน เหมาะกับงานแบบไหน และวิธีเช็กว่าเครื่องรองรับ |
| [Foundation Models](foundation-models.md) | พื้นฐาน `LanguageModelSession` บน device: ถาม-ตอบ, streaming, `@Generable` |
| [Tool calling](tool-calling.md) | ให้ model เรียกฟังก์ชันของเราเพื่อดึงข้อมูลหรือทำ action ใน app |
| [HackathonAI](hackathon-ai.md) | Setup API key, ใช้ model บน cluster, fallback และกติกาการใช้ cluster ร่วมกัน |

## ลงมือปฏิบัติ { #hands-on }

ทุกคนสร้าง **StudyNotes** app จดโน้ตที่มี AI ช่วยทบทวน จาก [starter repo](https://github.com/swiftcodingclubth/study-notes) ทุก feature run บน device จึงทำได้ทุกเครื่อง เขียนโค้ดใน `NoteAssistant.swift` ตาม `// TODO`

1. **ซ่อนปุ่ม AI** บนเครื่องที่ไม่รองรับ ดู [เช็กว่าเครื่องรองรับไหม](models.md#availability)
2. **สรุปโน้ต** 2 ประโยค พร้อมสวิตช์ Precise / Creative ดู [Foundation Models](foundation-models.md)
3. **สร้าง study card** ด้วย `@Generable` ดู [`@Generable`](foundation-models.md#generable-model-structured-output)
4. **ตั้งเวลาทบทวน** ด้วย tool ที่สร้าง reminder ในแอป Reminders ดู [Tool calling](tool-calling.md)
5. **Stream study card** ให้ค่อยๆ เติมบนจอ ดู [Streaming](foundation-models.md#streaming)
6. **ติด tag อัตโนมัติ** ด้วย content tagging model แล้วกรองโน้ตตาม tag

# Bring intelligence to your app with Foundation Models and on-prem AI

Workshop นี้ทำให้ app ของทีมใช้ language model ได้ ทั้ง model ที่ run บน iPad, บน server ของ Apple และบน AI cluster ของงาน ด้วยโค้ดชุดเดียวกัน เหมาะกับ idea ที่ต้องใช้ภาษา เช่น สรุป แปล ตอบคำถาม หรือจัดข้อความให้เป็นข้อมูลที่มีโครงสร้าง

## สิ่งที่จะได้เรียน { #outcomes }

1. **เลือก model ให้เหมาะกับงาน**: เข้าใจว่าแต่ละที่ต่างกันอย่างไรในเรื่อง privacy, ความเร็ว, ความเก่ง, ภาษาไทย และการใช้งานนอกสถานที่
2. **ใช้ `LanguageModelSession`**: ถามแล้วได้คำตอบ, แสดงคำตอบทีละส่วน (streaming), ให้ model ตอบเป็น Swift struct (`@Generable`) และให้ model เรียกฟังก์ชันของเรา (tool calling)
3. **ใช้ AI cluster**: เรียก model ที่ใหญ่กว่าบนเครื่องของงานผ่าน package **HackathonAI** เมื่องานยากเกินกว่า on-device
4. **รับมือเมื่อ model ใช้ไม่ได้**: เช็กว่า iPad มี Apple Intelligence ไหม และถ้า AI cluster ไม่ว่างหรือเชื่อมต่อไม่ได้ ให้ app ถอยกลับมาใช้ on-device model เองโดยไม่ crash

## แนวคิดหลัก { #concepts }

### ประเภทต่างๆของ Language model

- **On-device AFM 3**: Apple Foundation Models รุ่นที่ 3 run บน iPad เลย ฟรี ข้อมูลไม่ออกจากเครื่อง ตอบเร็ว และใช้ได้แม้ไม่มี internet แต่ model มีขนาดเล็ก เหมาะกับงานสั้นๆ ที่ไม่ซับซ้อน
- **Private Cloud Compute (PCC)**: AFM 3 ที่ run บน server ของ Apple เก่งกว่าบน device และ Apple ออกแบบให้ข้อมูลยังเป็นส่วนตัว แต่ต้องต่อ internet
- **AI cluster**: กลุ่ม Mac ที่ผู้จัด run open-source model ไว้ให้ เช่น Gemma 4, Qwen3.8, MedGemma และ Typhoon OCR ใช้ได้เฉพาะใน Wi-Fi ของงาน ดู[รายชื่อ model](hackathon-ai.md#models)

### เปลี่ยนประเภทของ Language model ได้ง่ายๆ

`@Generable` struct ตัวเดียวกันใช้ได้กับทุก model ถ้าจะสลับไป AI cluster ก็แค่เปลี่ยนว่าเรียกใคร โครงสร้างคำตอบเหมือนเดิม

```swift
// On-device AFM 3
let a = try await LanguageModelSession()
    .respond(to: "Make a study card: \(text)", generating: StudyCard.self).content

// AI cluster: struct เดิม แค่เปลี่ยนคนตอบ
let b = try await aiCluster.respond(to: "Make a study card: \(text)", generating: StudyCard.self)
```

เริ่มจาก on-device ก่อนเสมอ แล้วค่อยส่งงานที่ยากหรือต้องการภาษาไทยที่ดีกว่าไปที่ PCC หรือ AI cluster ดูวิธีเลือกได้ที่ [เลือก model](models.md)

## MacBook แต่ละเครื่องทำอะไรได้บ้าง { #machines }

Feature บางอย่างต้องใช้ iOS 27 SDK ซึ่งมีเฉพาะใน Xcode 27 บน {{ mac.apple }}

!!! mchip "{{ mac.apple }} · Xcode 27"
    ทำได้ครบทุกส่วน: ใช้ on-device AFM 3, ส่ง model ของ AI cluster เข้า `LanguageModelSession` ได้โดยตรง, ใช้ PCC, [Dynamic Profile](dynamic-profiles.md) และส่งรูปให้ AFM 3 วิเคราะห์

!!! intel "{{ mac.intel }} · Xcode 26"
    ใช้ `LanguageModelSession` กับ on-device AFM 3 ได้ตามปกติ และเรียก AI cluster ผ่าน `aiCluster.respond(...)` ได้ รวมถึง `@Generable` แต่ iOS 26 SDK ยังส่ง model ของงานเข้า session ไม่ได้ จึงไม่มี tool calling และ Dynamic Profile กับ AI cluster

## หัวข้อหลัก { #pages }

อ่านตามลำดับนี้จะเข้าใจง่ายที่สุด

| หน้า | เนื้อหา |
|---|---|
| [เลือก model](models.md) | Model แต่ละตัว run ที่ไหน เหมาะกับงานแบบไหน และวิธีเช็กว่าเครื่องรองรับ |
| [Foundation Models](foundation-models.md) | พื้นฐาน `LanguageModelSession` บน device: ถาม-ตอบ, streaming, `@Generable` |
| [Tool calling](tool-calling.md) | ให้ model เรียกฟังก์ชันของเราเพื่อดึงข้อมูลหรือทำ action ใน app |
| [AI cluster](hackathon-ai.md) | Reference: model ที่มีในงาน, setup, วิธีเรียก, fallback และกติกาการใช้ร่วมกัน |
| [แบบฝึกหัด: Exam coach](exam-coach.md) | ต่อยอด StudyNotes ด้วยข้อสอบที่ยากขึ้นเมื่อตอบถูก โดยใช้ AI cluster |

## ลงมือปฏิบัติ { #hands-on }

ใช้ app **StudyNotes** ตลอด workshop เริ่มจากทำ feature บน on-device ตามหน้า [Foundation Models](foundation-models.md), [Tool calling](tool-calling.md) และ [Dynamic Profile](dynamic-profiles.md) แล้วต่อยอดด้วย model ที่ใหญ่กว่าใน [แบบฝึกหัด Exam coach](exam-coach.md)

1. **ใส่ address และ API key** ใน `AICluster.swift` ดู [Setup](hackathon-ai.md#setup)
2. **ทำ Exam coach** ตามขั้นตอนใน[แบบฝึกหัด](exam-coach.md)
3. **แสดงใน UI ว่า model ไหนเป็นคนตอบ** เช่น ป้าย "AI cluster" หรือ "On-device" จะได้รู้ว่า fallback ทำงานอยู่หรือเปล่า
4. **ทดสอบ fallback** ปิด Wi-Fi บน iPad แล้วทำข้อสอบอีกครั้ง app ต้องยังทำงานได้และป้ายเปลี่ยนเป็น "On-device"

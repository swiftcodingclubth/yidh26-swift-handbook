# เลือก model

ไม่มี model ไหนดีที่สุดในทุกสถานการณ์ model ขนาดเล็กแต่อยู่บนเครื่องจะเร็วและมีความเป็นส่วนตัว ส่วน model ขนาดใหญ่บน server จะเก่งกว่าแต่ต้องพึ่งพา network ในการใช้งาน

## ประเภทต่างๆของ Language model

| Model | Run ที่ไหน | ใช้ผ่าน | หมายเหตุ |
|---|---|---|---|
| **AFM 3 Core** | บน device | `LanguageModelSession` (iOS 26+) | มีในทุกเครื่องที่รองรับ Apple Intelligence รวมถึง iPad M chip ทุกรุ่น ฟรี ข้อมูลไม่ออกจากเครื่อง และใช้ได้แม้ไม่มี internet |
| **AFM 3 Core Advanced** | บน device | `LanguageModelSession` (iOS 27) | Model ที่ใหญ่กว่า run ได้เฉพาะ M3/M4 ที่มี memory 12 GB ขึ้นไป และ iPhone 17 Pro คิดเป็นเหตุเป็นผลและเข้าใจรูปได้ดีกว่า Core ชัดเจน |
| **AFM 3 on PCC** | Cloud ของ Apple | `LanguageModelSession` (iOS 27) | ใช้ได้ฟรี เก่งกว่าบน device และ Apple ออกแบบให้ข้อมูลยังเป็นส่วนตัว แต่ต้องต่อ internet |
| **Model บน cluster** | Mac cluster ในงาน | HackathonAI (iOS 27) หรือ `OnPremClient` (iOS 26) | Open-source model ที่ผู้จัดเลือกมาสำหรับงานเฉพาะ เช่น ภาษาไทยและการแพทย์ ใช้ได้เฉพาะใน Wi-Fi ของงาน |

## เลือก model อย่างไร

เริ่มจาก on-device เสมอ ถ้าผลลัพธ์ยังไม่ดีพอค่อยขยับไปใช้ model ที่ใหญ่กว่า

| ถ้าต้องการ… | ใช้ | เพราะ |
|---|---|---|
| ข้อมูลไม่ออกจากเครื่อง, ใช้ offline, ตอบเร็ว | On-device AFM 3 | ไม่ต้องส่งข้อมูลผ่าน network เลย |
| งานซับซ้อนกว่าที่ on-device ทำได้ | PCC หรือ `.general` บน cluster | Model ใหญ่กว่า เข้าใจโจทย์ยาวๆ ได้ดีกว่า |
| ภาษาไทยที่เป็นธรรมชาติกว่า | `.thai` บน cluster | Model ที่ train มาเพื่อภาษาไทยโดยเฉพาะ |
| ข้อความทางการแพทย์ | `.medical` บน cluster | เข้าใจศัพท์และบริบททางการแพทย์ได้ดีกว่า model ทั่วไป |
| Demo ที่ต้องไม่พังนอกงาน | On-device เป็นหลัก cluster เป็นตัวเสริม | Cluster ใช้ได้เฉพาะใน Wi-Fi ของงาน |

## Model บน cluster

แต่ละ model มี **constant** ใน package HackathonAI ไว้เลือกใช้ เช่น `.thai` และรองรับ feature ไม่เท่ากัน

| Use case | Constant | Model | รองรับ |
|---|---|---|---|
| ทั่วไป / reasoning | `.general` | [model name] | [structured output · tools · context size] |
| ภาษาไทย | `.thai` | [model name] | [structured output · tools · context size] |
| การแพทย์ | `.medical` | [model name] | [structured output · tools · context size] |
| เข้าใจรูป | `.vision` | [model name] | [image input · structured output] |

ความหมายของช่อง "รองรับ":

- **Structured output**: ใช้กับ `@Generable` ได้ ให้ model ตอบเป็น Swift struct
- **Tools**: ใช้กับ tool calling ได้ ให้ model เรียกฟังก์ชันของเรา
- **Context size**: ความยาวสูงสุดของข้อความที่ส่งเข้าไปรวมกับคำตอบ ถ้าเกินจะ error
- **Image input**: ส่งรูปให้ model วิเคราะห์ได้

!!! note "Feature ที่ model ไม่รองรับ"
    ถ้าใช้ `@Generable` หรือ tool calling กับ model ที่ไม่รองรับ HackathonAI จะ error ทันทีแทนที่จะส่ง request ไป ดูช่อง "รองรับ" ก่อนเลือก model

## ข้อมูลการเชื่อมต่อ

| รายการ | ค่า |
|---|---|
| Base URL | [https://…] |
| Swift package | [GitHub URL และ version tag] |
| Team API key | อยู่บน [Team card](../getting-started.md#1-team-card) |
| Rate limit ต่อทีม | [requests ต่อนาที · concurrent requests สูงสุด] |
| Status page | [URL] ดูว่า model ไหนว่างหรือมีคิวยาว |

## เช็กว่าเครื่องรองรับไหม { #availability }

ไม่ใช่ทุกเครื่องจะใช้ on-device model ได้ เช่น iPad รุ่นเก่า หรือเครื่องที่ผู้ใช้ปิด Apple Intelligence ไว้ ถ้าเรียกใช้โดยไม่เช็กก่อน app จะ error ให้เช็ก `availability` ก่อนแสดง feature และเตรียมทางเลือกไว้ทุกกรณี

```swift
import FoundationModels

switch SystemLanguageModel.default.availability {
case .available:
    // ใช้ on-device model ได้
case .unavailable(.deviceNotEligible):
    // เครื่องไม่รองรับ: ใช้ model บน cluster แทน หรือซ่อน feature นี้
case .unavailable(.appleIntelligenceNotEnabled):
    // รองรับแต่ปิดอยู่: บอกผู้ใช้ให้เปิด Apple Intelligence ใน Settings
case .unavailable(.modelNotReady):
    // Model ยังดาวน์โหลดไม่เสร็จ: แสดงข้อความแล้วลองใหม่ภายหลัง
case .unavailable:
    // กรณีอื่นที่อาจเพิ่มมาในอนาคต
}
```

!!! mchip "{{ mac.apple }} · Xcode 27"
    **AFM 3 Core Advanced**: บนเครื่องที่รองรับ (M3/M4, memory 12 GB ขึ้นไป) จะได้ AFM 3 Core Advanced ที่เก่งกว่าและส่งรูปให้ model ได้ เครื่องอื่นยังใช้ AFM 3 Core ได้ตามปกติ ออกแบบ feature ให้ทำงานได้กับทั้งสองแบบ แล้วค่อยเพิ่มความสามารถเมื่อเครื่องรองรับ

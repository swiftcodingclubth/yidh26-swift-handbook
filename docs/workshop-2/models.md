# เลือก model

ไม่มี model ไหนดีที่สุดในทุกสถานการณ์ model ขนาดเล็กแต่อยู่บนเครื่องจะเร็วและมีความเป็นส่วนตัว ส่วน model ขนาดใหญ่บน server จะเก่งกว่าแต่ต้องพึ่งพา network ในการใช้งาน

## ประเภทต่างๆของ Language model

| Model | Run ที่ไหน | ใช้ผ่าน | หมายเหตุ |
|---|---|---|---|
| **AFM 3 Core** | บน device | `LanguageModelSession` (iOS 26+) | มีในทุกเครื่องที่รองรับ Apple Intelligence รวมถึง iPad M chip ทุกรุ่น ฟรี ข้อมูลไม่ออกจากเครื่อง และใช้ได้แม้ไม่มี internet |
| **AFM 3 Core Advanced** | บน device | `LanguageModelSession` (iOS 27) | Model ที่ใหญ่กว่า run ได้เฉพาะ M3/M4 ที่มี memory 12 GB ขึ้นไป และ iPhone 17 Pro คิดเป็นเหตุเป็นผลและเข้าใจรูปได้ดีกว่า Core ชัดเจน |
| **AFM 3 on PCC** | Cloud ของ Apple | `LanguageModelSession` (iOS 27) | ใช้ได้ฟรี เก่งกว่าบน device และ Apple ออกแบบให้ข้อมูลยังเป็นส่วนตัว แต่ต้องต่อ internet |
| **AI cluster** | Mac cluster ในงาน | Package HackathonAI (iOS 26+) | Open-source model ที่ใหญ่กว่า on-device: Smart Route (Gemma 4 / Qwen3.6), Qwen3.8 27B, MedGemma, Typhoon OCR และ model เสียง ใช้ได้เฉพาะใน Wi-Fi ของงาน |

## เลือก model อย่างไร

เริ่มจาก on-device เสมอ ถ้าผลลัพธ์ยังไม่ดีพอค่อยขยับไปใช้ model ที่ใหญ่กว่า

| ถ้าต้องการ… | ใช้ | เพราะ |
|---|---|---|
| ข้อมูลไม่ออกจากเครื่อง, ใช้ offline, ตอบเร็ว | On-device AFM 3 | ไม่ต้องส่งข้อมูลผ่าน network เลย |
| งานซับซ้อนกว่าที่ on-device ทำได้, ข้อความยาว | PCC หรือ Smart Route บน AI cluster | Model ใหญ่กว่า เข้าใจโจทย์ยาวๆ และภาษาไทยได้ดีกว่า |
| โจทย์ที่ต้องคิดหลายขั้น, วิเคราะห์เอกสารหรือรูป | `.reasoning` บน AI cluster | Qwen3.8 คิดก่อนตอบและรับรูปได้ |
| อ่านข้อความภาษาไทยจากรูป | `.ocr` บน AI cluster | Typhoon OCR ทำมาเพื่อเอกสารภาษาไทย |
| ข้อความทางการแพทย์ | `.medical` บน AI cluster | เข้าใจศัพท์และบริบททางการแพทย์ได้ดีกว่า model ทั่วไป |
| Demo ที่ต้องไม่พังนอกงาน | On-device เป็นหลัก AI cluster เป็นตัวเสริม | AI cluster ใช้ได้เฉพาะใน Wi-Fi ของงาน |

## AI cluster { #ai-cluster }

Model ทั้งหมดที่ run บน AI cluster ของงาน, ความสามารถของแต่ละตัว และวิธีเรียก อยู่ที่หน้า [AI cluster](hackathon-ai.md#models)

## เช็กว่าเครื่องรองรับไหม { #availability }

ไม่ใช่ทุกเครื่องจะใช้ on-device model ได้ เช่น iPad รุ่นเก่า หรือเครื่องที่ผู้ใช้ปิด Apple Intelligence ไว้ ถ้าเรียกใช้โดยไม่เช็กก่อน app จะ error ให้เช็ก `availability` ก่อนแสดง feature และเตรียมทางเลือกไว้ทุกกรณี

```swift
import FoundationModels

switch SystemLanguageModel.default.availability {
case .available:
    // ใช้ on-device model ได้
case .unavailable(.deviceNotEligible):
    // เครื่องไม่รองรับ: ใช้ AI cluster แทน หรือซ่อน feature นี้
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

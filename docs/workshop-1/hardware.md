# Hardware

แต่ละทีมมีอุปกรณ์พัฒนา 2 แบบที่แตกต่างกัน คือ {{ mac.apple }} และ {{ mac.intel }}  ในงานที่จำเป็นต้องใช้ feature บน iOS 27 จะต้องทำบน {{ mac.apple }} ส่วนงานอื่นๆทั้งหมดสามารถทำบน {{ mac.intel }} ได้

## อุปกรณ์ของแต่ละทีม

| อุปกรณ์ | จำนวน | Software | หน้าที่ |
|---|---|---|---|
| {{ mac.apple }} | 1 | macOS Tahoe 26.6+ · Xcode 27 | เครื่องหลักของทีม ใช้ API ใหม่ของ iOS 27 และ Xcode agents |
| {{ mac.intel }} | 2 | macOS Sequoia 15.6+ · Xcode 26 | งานที่ไม่จำเป็นต้องใช้ iOS 27: เขียนโค้ด, build, test บน iPad, Git และ OpenCode |
| iPad M chip | 1 | iPadOS 27 · Developer Mode | Test device รองรับ Apple Intelligence และมีกล้อง |

## เครื่องไหนทำอะไรได้

| ความสามารถ | {{ mac.intel }} · Xcode 26 | {{ mac.apple }} · Xcode 27 |
|---|:---:|:---:|
| SwiftUI, build, run บน iPad | ✓ | ✓ |
| Git และ GitHub | ✓ | ✓ |
| OpenCode | ✓ | ✓ |
| Xcode agents | ✗ | ✓ |
| API ใหม่ของ iOS 27 | ✗ | ✓ |

!!! intel "{{ mac.intel }} · Xcode 26"
    ใช้ Xcode 27 ไม่ได้ เพราะ Xcode 27 รองรับเฉพาะ Apple silicon ส่วน Xcode agents ต้องใช้ macOS 26.2 ขึ้นไป {{ mac.intel }} จึงใช้ Xcode 26 กับ OpenCode แทน

    Xcode 26 ยังมี Foundation Models, App Intents, Vision, VisionKit, Create ML และ Core ML ครบ งานส่วนใหญ่ของ hackathon จึงทำบน {{ mac.intel }} ได้

## iPad แต่ละรุ่นต่างกัน

iPad ทุกเครื่องเป็น M chip แต่บาง feature ขึ้นกับรุ่นและ memory ดูรุ่นของ iPad ทีมได้จาก Team card ก่อนเลือก feature ที่จะทำ

| Feature | รุ่นที่รองรับ |
|---|---|
| AFM 3 Core (on-device model) | iPad M chip ทุกรุ่น |
| AFM 3 Core Advanced | M3 หรือ M4 ที่มี memory 12 GB ขึ้นไป |
| LiDAR | iPad Pro เท่านั้น |

!!! tip "Test บน iPad จริงเสมอ"
    Simulator จำลองได้ไม่ครบ กล้อง, sensor และ Apple Intelligence ทำงานได้ครบบน iPad จริงเท่านั้น แต่ละคนใช้ iPad ของตัวเองเป็นเครื่อง test ตลอดงาน

# Build sensor-aware intelligence with Core AI and Create ML

iPad มี sensor ที่เว็บไซต์ไม่มีทางเข้าถึงได้: **การเคลื่อนไหว** จาก accelerometer และ gyroscope, **เสียง** จากไมโครโฟน, **ความลึก** จาก LiDAR และภาพจากกล้อง เมื่อนำข้อมูลเหล่านี้มาให้ AI ที่ run บนเครื่องวิเคราะห์ app จะรับรู้สิ่งที่เกิดขึ้นรอบตัวผู้ใช้ได้ทันที เช่น นับจำนวนครั้งที่ออกกำลังกาย ได้ยินเสียงสัญญาณเตือน หรือวัดระยะห่างของสิ่งของ

Workshop 2 ใช้ language model ที่มีอยู่แล้ว ส่วน workshop นี้จะ **train model ของเราเอง** จากข้อมูล sensor แล้ว run บน iPad และใช้ Core AI เปลี่ยนผลลัพธ์ให้เป็นคำแนะนำที่อ่านเข้าใจง่าย

## สิ่งที่จะได้เรียน { #outcomes }

1. **อ่านข้อมูล sensor**: การเคลื่อนไหวด้วย Core Motion, ความลึกจาก LiDAR ด้วย ARKit และจดจำเสียงกว่า 300 แบบด้วย Sound Analysis โดยไม่ต้อง train
2. **Train model เองโดยไม่ต้องเขียนโค้ด**: อัดท่าทางหรือเสียงที่ต้องการ แล้ว train ใน Create ML
3. **Run model กับข้อมูลสดใน app**: ใช้ class ที่ Xcode สร้างให้ ทำให้ผลลัพธ์นิ่งไม่กระพริบ และประหยัดแบตเตอรี่ด้วย sampling rate ที่เหมาะสม
4. **ใช้ Core AI**: run open-source language model บนเครื่อง เพื่อเปลี่ยนผลจาก sensor เป็นคำแนะนำ

## แนวคิดหลัก { #concepts }

### เลือกเครื่องมือ

| ถ้าต้องการ… | ใช้ | ตัวอย่าง |
|---|---|---|
| จดจำเสียงทั่วไปโดยไม่ต้อง train | **Sound Analysis** | ได้ยินเสียงกริ่ง เสียงเด็กร้อง เสียงสัญญาณเตือน |
| จดจำท่าทาง เสียง หรือภาพแบบที่เรากำหนดเอง | **Create ML** (train) | Train ให้รู้จัก 3 ท่า: เขย่า เอียง วาดวงกลม |
| Run model ที่ train แล้วใน app | **Core ML** | ส่งข้อมูล gyroscope สดๆ ให้ model ทายท่า |
| ให้ language model run บนเครื่อง | **Core AI** | เปลี่ยนผลที่ทายได้ เป็นคำแนะนำการออกกำลังกาย |

### Sensor ที่ใช้ได้

| Sensor | Framework | มีในเครื่องไหน | ไอเดีย |
|---|---|---|---|
| [Accelerometer & gyroscope](core-motion.md) | Core Motion | ทุกเครื่อง | จดจำท่าทาง, นับครั้งออกกำลังกาย, ตรวจจับการเขย่าหรือการล้ม |
| [Barometer](core-motion.md#barometer) | Core Motion | ทุกรุ่นที่ใช้ในงาน (เช็กในโค้ดเสมอ) | ขึ้นลงชั้น การเปลี่ยนความสูง |
| [Microphone](sound.md) | Sound Analysis | ทุกเครื่อง | แจ้งเตือนเมื่อได้ยินเสียงสำคัญ, จดจำเสียงที่ train เอง |
| [LiDAR](lidar.md) | ARKit | iPad Pro และ iPhone Pro เท่านั้น | วัดขนาดและระยะ, เตือนสิ่งกีดขวาง, เช็กว่าของวางพอดีไหม |
| Camera | AVFoundation, Vision | ทุกเครื่อง | ดู [Workshop 5](../workshop-5/index.md) |
| Apple Pencil | PencilKit | เมื่อเชื่อม Pencil | จดจำลายมือหรือภาพวาดจากแรงกดและมุมเอียง |

!!! tip "ใช้ iPhone เป็น sensor เพิ่มได้"
    ถ้า iPhone ของตัวเองลงทะเบียนสำหรับ development แล้ว ใช้ run app เพื่อเทียบ sensor กับ iPad ได้

## MacBook แต่ละเครื่องทำอะไรได้บ้าง { #machines }

!!! mchip "{{ mac.apple }} · Xcode 27"
    ทำได้ทุกส่วน รวมถึง [Core AI](core-ai.md)

!!! intel "{{ mac.intel }} · Xcode 26"
    ทำได้เกือบทั้ง workshop: อ่าน sensor, จดจำเสียง, train model ใน Create ML และ run ด้วย Core ML บน iPad ส่วน Core AI ต้องใช้ Xcode 27 ให้นั่งคู่กับเพื่อนที่ใช้ {{ mac.apple }} ช่วงนั้น

    Create ML บน {{ mac.intel }} train ช้ากว่า ให้ใช้ข้อมูลน้อยๆ: 3 ท่า ท่าละไม่กี่ครั้ง

## หัวข้อหลัก { #pages }

อ่านตามลำดับนี้จะเข้าใจง่ายที่สุด

| หน้า | เนื้อหา |
|---|---|
| [Core Motion](core-motion.md) | อ่านการเคลื่อนไหว, เลือก sampling rate, ตรวจจับท่าแบบง่าย และเก็บข้อมูลให้ model |
| [Sound recognition](sound.md) | จดจำเสียงกว่า 300 แบบด้วย classifier ในตัว และใช้ model เสียงที่ train เอง |
| [LiDAR](lidar.md) | อ่านความลึกและวัดระยะ บน iPad Pro |
| [Create ML](create-ml.md) | อัดข้อมูลแล้ว train model เองโดยไม่ต้องเขียนโค้ด |
| [Core ML](core-ml.md) | Run model กับข้อมูลสด และประหยัดแบตเตอรี่ |
| [Core AI](core-ai.md) | Run open-source language model บน {{ mac.apple }} |

## ลงมือปฏิบัติ { #hands-on }

### Motion Coach

สร้าง app ที่จดจำท่าทางจากการเคลื่อนไหวของ iPad แบบ real time แล้วแสดงชื่อท่าและความมั่นใจบนจอ

1. **เลือก 3 ท่า** เช่น เขย่า, เอียงซ้าย-ขวา และวาดวงกลมในอากาศ ท่าควรต่างกันชัดเจน model จะได้แยกออก
2. **อัดข้อมูล** แต่ละคนใช้ recorder app ใน starter repo อัดท่าละไม่กี่วินาที หลายๆ รอบ ดู [Create ML](create-ml.md#activity-classifier)
3. **Train** รวมข้อมูลของทั้งทีมแล้ว train activity classifier ใน Create ML
4. **Run ใน app** ส่งข้อมูล Core Motion สดให้ model แสดงชื่อท่าและความมั่นใจบนจอ ดู [Core ML](core-ml.md)
5. **ทำให้นิ่ง** ใช้ผลหลายครั้งล่าสุดช่วยตัดสิน หน้าจอจะได้ไม่กระพริบไปมา ดู [ทำให้ผลลัพธ์นิ่ง](core-ml.md#smoothing)

!!! tip "ตามไม่ทัน"
    อัดข้อมูลไม่ทัน ขอ dataset สำรองจาก TA แล้วข้ามไปขั้น 3 ได้เลย

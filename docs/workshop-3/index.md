# Build sensor-aware intelligence with Core AI and Create ML

iPhone และ iPad มี sensor หลายตัวที่รับรู้สิ่งรอบตัวได้ เช่น

* **การเคลื่อนไหว** จาก accelerometer และ gyroscope
* **เสียง** จากไมโครโฟน
* **ความลึก** จาก LiDAR
* **ภาพ** จากกล้อง

เมื่อให้ AI ที่ run บนเครื่องวิเคราะห์ข้อมูลเหล่านี้ app จะรู้ทันทีว่าเกิดอะไรขึ้นรอบตัวผู้ใช้ เช่น นับจำนวนครั้งที่ออกกำลังกาย แจ้งเตือนเมื่อได้ยินเสียงสัญญาณ หรือวัดระยะห่างของสิ่งของ

Workshop 2 ใช้ language model ที่มีอยู่แล้ว ส่วน workshop นี้จะ **train model ของเราเอง** จากข้อมูล sensor แล้ว run บน iPad และใช้ Core AI เปลี่ยนผลลัพธ์ให้เป็นคำแนะนำที่เข้าใจง่าย

## สิ่งที่จะได้เรียน { #outcomes }

1. **อ่านข้อมูล sensor**: การเคลื่อนไหวด้วย Core Motion, ความลึกจาก LiDAR ด้วย ARKit และจดจำเสียงกว่า 300 แบบด้วย Sound Analysis โดยไม่ต้อง train
2. **Train model เองโดยไม่ต้องเขียนโค้ด**: อัดท่าทางหรือเสียงที่ต้องการ แล้ว train ใน Create ML
3. **Run model กับข้อมูลสดใน app**: ใช้ class ที่ Xcode สร้างให้ ทำให้ผลลัพธ์นิ่งไม่กระพริบ และประหยัดแบตเตอรี่ด้วย sampling rate ที่เหมาะสม
4. **ใช้ Core AI**: run open-source language model บนเครื่อง เพื่อเปลี่ยนผลจาก sensor เป็นคำแนะนำ

## แนวคิดหลัก { #concepts }

### เลือกเครื่องมือ

| ถ้าต้องการ… | ใช้ | ตัวอย่าง |
|---|---|---|
| อ่านการเคลื่อนไหว หรือตรวจจับท่าง่าย ๆ โดยไม่ต้อง train | **Core Motion** | รู้ว่าผู้ใช้เขย่าหรือเอียง iPad, นับการขึ้นลงชั้นด้วย barometer |
| วัดความลึกและระยะ | **ARKit** (LiDAR) | วัดขนาดโต๊ะ, เตือนเมื่อมีสิ่งกีดขวางใกล้เกินไป |
| จดจำเสียงทั่วไปโดยไม่ต้อง train | **Sound Analysis** | ได้ยินเสียงกริ่ง เสียงเด็กร้อง เสียงสัญญาณเตือน |
| จดจำท่าทาง เสียง หรือภาพแบบที่เรากำหนดเอง | **Create ML** (train) | Train ให้รู้จัก 3 ท่า: เขย่า เอียง วาดวงกลม |
| Run model ที่ train แล้วใน app | **Core ML** | ส่งข้อมูล gyroscope ให้ model ทายท่า |
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

## ลองจับคู่ { #tool-sort }

ลาก card แต่ละใบไปวางที่เครื่องมือที่ใช้ทำงานนั้น บน iPad ใช้นิ้วลากได้ หรือแตะ card แล้วแตะเครื่องมือก็ได้

<div class="tool-sort" markdown="0">
  <div class="tool-sort__status" aria-live="polite">
    <span class="tool-sort__score"></span>
    <span class="tool-sort__feedback"></span>
    <button type="button" class="tool-sort__reset">เริ่มใหม่</button>
  </div>
  <div class="tool-sort__pool">
    <button type="button" class="tool-sort__card" data-answer="motion" data-hint="ใช้ค่า userAcceleration จาก Core Motion ตั้งเงื่อนไขเอง ไม่ต้อง train">รู้ว่าผู้ใช้เขย่า iPad</button>
    <button type="button" class="tool-sort__card" data-answer="motion" data-hint="Barometer อยู่ใน Core Motion: CMAltimeter">นับว่าเดินขึ้นบันไดไปกี่ชั้น</button>
    <button type="button" class="tool-sort__card" data-answer="lidar" data-hint="ความลึกจาก LiDAR อ่านผ่าน ARKit">วัดความกว้างของโต๊ะ</button>
    <button type="button" class="tool-sort__card" data-answer="lidar" data-hint="ต้องรู้ระยะของสิ่งที่อยู่ข้างหน้า ใช้ความลึกจาก LiDAR">เตือนเมื่อมีสิ่งกีดขวางใกล้กว่า 1 เมตร</button>
    <button type="button" class="tool-sort__card" data-answer="sound" data-hint="เสียงกริ่งเป็นหนึ่งในกว่า 300 เสียงที่ classifier ในตัวรู้จักอยู่แล้ว">แจ้งเตือนเมื่อได้ยินเสียงกริ่งประตู</button>
    <button type="button" class="tool-sort__card" data-answer="createml" data-hint="ท่าที่เรากำหนดเองต้อง train model ก่อน ใน Create ML">สอนให้รู้จักท่าวาดวงกลมในอากาศ</button>
    <button type="button" class="tool-sort__card" data-answer="coreml" data-hint="Model ที่ train แล้ว run ใน app ด้วย Core ML">ทายท่าจาก gyroscope ใน app</button>
    <button type="button" class="tool-sort__card" data-answer="coreai" data-hint="เปลี่ยนตัวเลขเป็นข้อความที่อ่านง่าย เป็นงานของ language model">เปลี่ยนผล "squat 10 ครั้ง" เป็นคำแนะนำ</button>
  </div>
  <div class="tool-sort__zones">
    <div class="tool-sort__zone" data-tool="motion" role="button" tabindex="0"><strong>Core Motion</strong><small>การเคลื่อนไหว, barometer</small><div class="tool-sort__drop"></div></div>
    <div class="tool-sort__zone" data-tool="lidar" role="button" tabindex="0"><strong>ARKit (LiDAR)</strong><small>ความลึกและระยะ</small><div class="tool-sort__drop"></div></div>
    <div class="tool-sort__zone" data-tool="sound" role="button" tabindex="0"><strong>Sound Analysis</strong><small>เสียงทั่วไป ไม่ต้อง train</small><div class="tool-sort__drop"></div></div>
    <div class="tool-sort__zone" data-tool="createml" role="button" tabindex="0"><strong>Create ML</strong><small>train model เอง</small><div class="tool-sort__drop"></div></div>
    <div class="tool-sort__zone" data-tool="coreml" role="button" tabindex="0"><strong>Core ML</strong><small>run model ใน app</small><div class="tool-sort__drop"></div></div>
    <div class="tool-sort__zone" data-tool="coreai" role="button" tabindex="0"><strong>Core AI</strong><small>language model บนเครื่อง</small><div class="tool-sort__drop"></div></div>
  </div>
</div>

## MacBook แต่ละเครื่องทำอะไรได้บ้าง { #machines }

!!! mchip "{{ mac.apple }} · Xcode 27"
    ทำได้ทุกส่วน รวมถึง [Core AI](core-ai.md)

!!! intel "{{ mac.intel }} · Xcode 26"
    ทำได้เกือบทั้ง workshop: อ่าน sensor, จดจำเสียง, train model ใน Create ML และ run ด้วย Core ML บน iPad ส่วน Core AI ต้องใช้ Xcode 27 ให้นั่งคู่กับเพื่อนที่ใช้ {{ mac.apple }} ช่วงนั้น

    Create ML บน {{ mac.intel }} train ช้ากว่า ให้ใช้ข้อมูลน้อย ๆ: 3 ท่า ท่าละไม่กี่ครั้ง

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
| [ใส่ใน app ของทีม](add-to-your-app.md) | Copy ไฟล์จาก starter, Info.plist, model และ prompt สำหรับ agent |

## ลงมือปฏิบัติ { #hands-on }

### Motion Coach

สร้าง app ที่จดจำท่าทางจากการเคลื่อนไหวของ iPad: กดเริ่ม ทำท่า แล้วกดหยุด app จะบอกชื่อท่าและความมั่นใจ

Starter project อยู่ในโฟลเดอร์ [`starter/workshop-3`](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-3) ของ repo handbook นี้ ดูวิธีเอามาใช้ใน[ใส่ใน app ของทีม](add-to-your-app.md#get-starter)

1. **เลือก 3 ท่า** เช่น เขย่า, เอียงซ้าย-ขวา และวาดวงกลมในอากาศ ท่าควรต่างกันชัดเจน model จะได้แยกออก
2. **อัดข้อมูล** แต่ละคนใช้ app [Motion Recorder](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-3-recorder) อัดท่าละไม่กี่วินาที หลาย ๆ รอบ ดู [Create ML](create-ml.md#activity-classifier)
3. **Train** รวมข้อมูลของทั้งทีมแล้ว train activity classifier ใน Create ML
4. **Run ใน app** อัดท่าแล้วส่งข้อมูลให้ model ทาย แสดงชื่อท่าบนจอ ดู [ทายท่าด้วย model](core-ml.md#predict) และวิธีใส่ใน app ของทีมที่[ใส่ใน app ของทีม](add-to-your-app.md#models)
5. **ไปต่อ** ให้ทายต่อเนื่องแบบ real time โดยไม่ต้องกดปุ่ม แล้วใช้ผลหลายครั้งล่าสุดช่วยตัดสิน หน้าจอจะได้ไม่กระพริบ ดู [ทายต่อเนื่องแบบ real time](core-ml.md#smoothing)

!!! tip "ตามไม่ทัน"
    อัดข้อมูลไม่ทัน ขอ dataset สำรองจาก TA แล้วข้ามไปขั้น 3 ได้เลย

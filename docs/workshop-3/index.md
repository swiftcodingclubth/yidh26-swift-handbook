# Teach your app to sense and understand with Core ML and Create ML

iPad รับรู้สิ่งรอบตัวได้มากกว่าที่เห็น และเข้าใจข้อมูลได้เองโดยไม่ต้องส่งขึ้น internet Workshop นี้แบ่งเป็น 2 ส่วน

**ส่วนที่ 1: รับรู้ด้วย sensor** ใช้ API ที่มีในระบบอยู่แล้ว ไม่ต้อง train

* **การเคลื่อนไหว** จาก accelerometer, gyroscope และ barometer ด้วย Core Motion
* **เสียง** จากไมโครโฟน จดจำได้กว่า 300 แบบด้วย Sound Analysis
* **ระยะ** จาก LiDAR ด้วย ARKit

**ส่วนที่ 2: เข้าใจด้วย machine learning** run model บน iPad ด้วย Core ML

* **Train model เอง** ด้วย Create ML โดยไม่ต้องเขียนโค้ด: อ่านข้อความแล้วบอกอารมณ์
* **ใช้ model สำเร็จรูปจาก Apple**: บอกว่าในรูปมีอะไร และหาวัตถุในรูป
* **ไปต่อด้วย Core AI**: ให้ language model เปลี่ยนผลที่ได้เป็นข้อความที่อ่านเข้าใจง่าย

Workshop 2 ใช้ language model ที่มีอยู่แล้ว ส่วน workshop นี้ใช้ model ที่ทำงานเฉพาะเรื่อง ซึ่งเล็กและเร็วกว่ามาก และ train เองได้ภายในไม่กี่วินาที

## สิ่งที่จะได้เรียน { #outcomes }

1. **อ่านข้อมูล sensor โดยไม่ต้อง train**: การเคลื่อนไหวด้วย Core Motion, เสียงด้วย Sound Analysis และความลึกจาก LiDAR ด้วย ARKit
2. **Train model เองโดยไม่ต้องเขียนโค้ด**: train text classifier ที่อ่านข้อความแล้วบอกอารมณ์ ใน Create ML และอ่านผลให้เป็น
3. **Run model ใน app ด้วย Core ML**: ใช้ model ที่ train เอง ใช้ความมั่นใจตัดสินผล และใช้ model สำเร็จรูปจาก Apple กับรูปภาพ
4. **ใช้ Core AI** (ไปต่อ): run open-source language model บนเครื่อง เพื่อเปลี่ยนผลจาก model เป็นคำแนะนำ

## แนวคิดหลัก { #concepts }

### ต้อง train model เองไหม { #train-or-not }

ไม่จำเป็นเสมอไป เริ่มจากสิ่งที่ระบบมีให้ก่อน แล้วค่อยขยับไปขั้นถัดไปเมื่อจำเป็น

| ขั้น | ใช้อะไร | ตัวอย่างใน workshop | ต้องเตรียม |
|---|---|---|---|
| 1. API ในระบบ | Core Motion, Sound Analysis, ARKit | เขย่าเพื่อสุ่ม, นับชั้น, แจ้งเตือนเสียงกริ่ง, วัดระยะ | ไม่ต้องเตรียมอะไร |
| 2. Model สำเร็จรูป | Core ML + model จาก Apple | บอกว่าในรูปมีอะไร, หาวัตถุในรูป | ดาวน์โหลดไฟล์ model |
| 3. Train เอง | Create ML + Core ML | อ่านข้อความแล้วบอกอารมณ์ | ข้อมูลที่ติด label ไว้ |

ขั้นที่ 3 ใช้เมื่อสิ่งที่ app ต้องการเฉพาะเจาะจงจนไม่มี API หรือ model สำเร็จรูปทำได้ และความแม่นขึ้นกับคุณภาพของข้อมูลมากที่สุด

### เลือกเครื่องมือ

| ถ้าต้องการ… | ใช้ | ตัวอย่าง |
|---|---|---|
| อ่านการเคลื่อนไหว หรือตรวจจับท่าง่าย ๆ ด้วยเงื่อนไข | **Core Motion** | รู้ว่าผู้ใช้เขย่าหรือเอียง iPad, นับการขึ้นลงชั้นด้วย barometer |
| วัดความลึกและระยะ | **ARKit** (LiDAR) | วัดขนาดโต๊ะ, เตือนเมื่อมีสิ่งกีดขวางใกล้เกินไป |
| จดจำเสียงทั่วไปโดยไม่ต้อง train | **Sound Analysis** | ได้ยินเสียงกริ่ง เสียงเด็กร้อง เสียงสัญญาณเตือน |
| สอน model ให้รู้จักสิ่งที่เรากำหนดเอง | **Create ML** (train) | Train ให้อ่านข้อความแล้วบอกอารมณ์ 6 แบบ |
| Run model ใน app | **Core ML** | พิมพ์ข้อความแล้วบอกอารมณ์, บอกว่าในรูปมีอะไร |
| ให้ language model run บนเครื่อง | **Core AI** | เปลี่ยนอารมณ์ที่ทายได้ เป็นข้อความให้กำลังใจ |

### Sensor ที่ใช้ได้

| Sensor | Framework | มีในเครื่องไหน | ไอเดีย |
|---|---|---|---|
| [Accelerometer & gyroscope](core-motion.md) | Core Motion | ทุกเครื่อง | ตรวจจับการเขย่าหรือการล้ม, เกมเอียงเครื่อง, นับก้าว |
| [Barometer](core-motion.md#barometer) | Core Motion | ทุกรุ่นที่ใช้ในงาน (เช็กในโค้ดเสมอ) | ขึ้นลงชั้น การเปลี่ยนความสูง |
| [Microphone](sound.md) | Sound Analysis | ทุกเครื่อง | แจ้งเตือนเมื่อได้ยินเสียงสำคัญ |
| [LiDAR](lidar.md) | ARKit | iPad Pro และ iPhone Pro เท่านั้น | วัดขนาดและระยะ, เตือนสิ่งกีดขวาง, เช็กว่าของวางพอดีไหม |
| Camera | AVFoundation, Vision | ทุกเครื่อง | ดู [Workshop 5](../workshop-5/index.md) และ model สำเร็จรูปในหน้า [Core ML](core-ml.md#pretrained) |
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
    <button type="button" class="tool-sort__card" data-answer="createml" data-hint="สิ่งที่เรากำหนดเองต้อง train model ก่อน ใน Create ML">สอน model ให้อ่านข้อความแล้วบอกอารมณ์</button>
    <button type="button" class="tool-sort__card" data-answer="coreml" data-hint="Model ที่ train แล้ว run ใน app ด้วย Core ML">ใช้ model ที่ train แล้วใน app</button>
    <button type="button" class="tool-sort__card" data-answer="coreml" data-hint="ใช้ model สำเร็จรูปจาก Apple (YOLOv3) run ด้วย Core ML ไม่ต้อง train">นับว่าในรูปมีสุนัขกี่ตัว</button>
    <button type="button" class="tool-sort__card" data-answer="coreai" data-hint="เขียนข้อความใหม่จากผลที่ได้ เป็นงานของ language model">เปลี่ยนผล "sadness 80%" เป็นข้อความให้กำลังใจ</button>
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

    Text classifier แบบ Maximum Entropy train บน {{ mac.intel }} ได้ในไม่กี่วินาที อย่าเลือก Transfer Learning เพราะจะช้ามาก

## หัวข้อหลัก { #pages }

อ่านตามลำดับนี้จะเข้าใจง่ายที่สุด

| ส่วน | หน้า | เนื้อหา |
|---|---|---|
| Sensor | [Core Motion](core-motion.md) | อ่านการเคลื่อนไหว, มุมเอียง, เลือก sampling rate, ตรวจจับท่าแบบง่าย และ barometer |
| Sensor | [Sound recognition](sound.md) | จดจำเสียงกว่า 300 แบบด้วย classifier ในตัว |
| Sensor | [LiDAR](lidar.md) | อ่านความลึกและวัดระยะ บน iPad Pro |
| ML | [Create ML](create-ml.md) | Template ที่มี, ข้อมูลที่ดี และ train text classifier บอกอารมณ์จากข้อความ |
| ML | [Core ML](core-ml.md) | Run model ที่ train เอง ใช้ความมั่นใจ และใช้ model สำเร็จรูปจาก Apple |
| ไปต่อ | [Core AI](core-ai.md) | Run open-source language model บน {{ mac.apple }} |
| | [ใส่ใน app ของทีม](add-to-your-app.md) | Copy ไฟล์จาก starter, Info.plist, model และ prompt สำหรับ agent |

## ลงมือปฏิบัติ { #hands-on }

Starter project อยู่ในโฟลเดอร์ [`starter/workshop-3`](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-3) ของ repo handbook นี้ ดูวิธีเอามาใช้ใน[ใส่ใน app ของทีม](add-to-your-app.md#get-starter)

### ลองใช้ starter project { #starter-tour }

แต่ละแท็บตรงกับหัวข้อในหน้านี้ เปิดดูตัวอย่างก่อนนำไปใช้ใน app ของทีม

| แท็บ | หน้าในแท็บ | Run บน |
|---|---|---|
| Motion | MotionView, AttitudeView, GravityView, RotationView, เอียงหรือไม่เอียง?, เขย่าสุ่มเมนู, คว่ำเครื่องจับเวลา, บิดข้อมือเปลี่ยนสไลด์, นับชั้น, เตือนเมื่อมีคนหยิบเครื่อง, พวงมาลัยเกมแข่งรถ, ไม้กายสิทธิ์, เกมใบ้คำ (workshop) | iPad จริง |
| Sound | SoundView, รายชื่อเสียงที่รู้จัก, แจ้งเตือนเสียงสำคัญ | Simulator หรือ iPad |
| LiDAR | DepthView, เตือนสิ่งกีดขวาง | iPad Pro |
| Core ML | ข้างใน model, วันนี้รู้สึกอย่างไร, ในรูปมีอะไร?, หาวัตถุในรูป, หาวัตถุแบบ live, ข้อความบวกหรือลบ, ใช้ model ของคนอื่น, ของบนโต๊ะคืออะไร (workshop) | Simulator หรือ iPad (หน้าที่ใช้กล้องสดต้องใช้ iPad) |

### วันนี้รู้สึกอย่างไร { #mood }

Train model ที่อ่านข้อความภาษาอังกฤษแล้วบอกอารมณ์ แล้วใช้ใน app: พิมพ์ความรู้สึก emoji และสีพื้นหลังเปลี่ยนตามอารมณ์ทันที

1. **ดูข้อมูล** เปิดไฟล์ในโฟลเดอร์ `EmotionData/` ของ starter project ดูว่าแต่ละอารมณ์มีประโยคแบบไหน ดู [Create ML](create-ml.md#data)
2. **Train** สร้าง Text Classifier ใน Create ML ด้วย `emotion6_train.csv` และทดสอบกับ `emotion6_test.csv`
3. **ทดสอบกับประโยคใหม่** กด + New Test ใส่ `emotion6_mytest.csv` และพิมพ์ประโยคเองในแท็บ Preview
4. **Run ใน app** Export เป็น `EmotionClassifier.mlmodel` วางแทนไฟล์เดิมใน starter แล้วเปิดหน้า "วันนี้รู้สึกอย่างไร" ดู [Core ML](core-ml.md#text-classifier)
5. **ไปต่อ** ปรับเกณฑ์ความมั่นใจ เพิ่มประโยคของอารมณ์ที่ทายพลาดบ่อย แล้ว train ใหม่ หรือส่งอารมณ์ที่ได้ให้ [Core AI](core-ai.md#mood-coach) เขียนข้อความให้กำลังใจ

!!! tip "ตามไม่ทัน"
    Train ไม่ทัน ใช้ `EmotionClassifier.mlmodel` ที่มีใน starter project ไปก่อน แล้วข้ามไปขั้น 4 ได้เลย

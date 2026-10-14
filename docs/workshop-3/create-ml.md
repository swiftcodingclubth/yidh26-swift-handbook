# Create ML

**Create ML** คือ app บน Mac ที่ train machine learning model ได้โดยไม่ต้องเขียนโค้ด เราแค่เตรียมตัวอย่างข้อมูลที่ติดป้ายไว้ว่าเป็นท่าอะไรหรือเสียงอะไร Create ML จะเรียนรู้รูปแบบจากตัวอย่างเหล่านั้น แล้วให้ไฟล์ model ที่นำไปใช้ใน app ได้ทันที ใช้ได้ทั้ง {{ mac.intel }} และ {{ mac.apple }}

เปิดได้จาก **Xcode › Open Developer Tool › Create ML**

## Model ที่ใช้ในงานนี้

| Template | Train จาก | ตัวอย่าง |
|---|---|---|
| **Activity Classifier** | ข้อมูล Core Motion ที่อัดไว้ | จดจำท่า เขย่า / เอียง / วาดวงกลม |
| **Sound Classifier** | ไฟล์เสียง | จดจำเสียงไอ เสียงเครื่องจักร เสียงที่ classifier ในตัวไม่รู้จัก |
| Image Classifier | รูปภาพ | แยกประเภทสิ่งของจากกล้อง |

## Activity Classifier

### 1. อัดข้อมูลท่าทาง

ใช้ app **Motion Recorder** ใน [`starter/workshop-3-recorder`](https://github.com/tawapnas/yidh26-swift-handbook/tree/main/starter/workshop-3-recorder) บน iPad เลือกชื่อท่า กดอัด (นับถอยหลัง 3 วินาที) ทำท่านั้นซ้ำๆ แล้วกดหยุด แต่ละครั้งจะได้ไฟล์ CSV หนึ่งไฟล์ ที่มีค่า Core Motion ทุก sample ที่ 50 Hz

- **ทำท่าละ 5–10 รอบ** รอบละไม่กี่วินาที ให้ทุกคนในทีมช่วยอัด model จะได้รู้จักท่าของหลายคน
- **จับเครื่องแบบเดียวกันทุกครั้ง** และแบบเดียวกับตอนใช้งานจริง ถ้าตอนอัดถือแนวตั้งแต่ตอนใช้ถือแนวนอน model จะทายผิด
- **ท่าควรต่างกันชัดเจน** ท่าที่คล้ายกันมาก model จะสับสน
- **อัด "ไม่ทำอะไร" ด้วย** เช่น ถือนิ่งๆ หรือวางบนโต๊ะ model จะได้ไม่ทายว่าเป็นท่าใดท่าหนึ่งตลอดเวลา

### 2. ส่งไฟล์มาที่ Mac

ใน Motion Recorder กด **ส่ง MotionData.zip** แล้วส่งด้วย **AirDrop** มาที่ Mac ดับเบิลคลิก zip จะได้ folder ที่แยกตามชื่อท่าไว้แล้ว:

```text
MotionData/
├── shake/
│   ├── shake-01.csv
│   └── shake-02.csv
├── tilt/
│   └── tilt-01.csv
├── circle/
│   └── circle-01.csv
└── idle/
    └── idle-01.csv
```

ชื่อ folder คือชื่อท่าที่ model จะตอบกลับมา

!!! tip "อัดข้อมูลไม่ทัน"
    ขอ dataset สำรองจาก TA แล้วเริ่มขั้นตอนถัดไปได้เลย

### 3. Train

1. Create ML › **New Document** › **Activity Classifier**
2. **Training Data**: ลาก folder `MotionData` มาวาง
3. **Features**: เลือก column ของค่า sensor ที่จะใช้ ไฟล์จาก Motion Recorder มี `accelX`, `accelY`, `accelZ` (ความเร่ง) และ `rotationX`, `rotationY`, `rotationZ` (การหมุน) ไม่ต้องเลือก `timestamp`
4. **Prediction Window Size**: จำนวน sample ที่ model ดูในแต่ละครั้ง ใช้ **100** (2 วินาทีที่ 50 Hz) ต้องตรงกับขนาด window ในโค้ด [Core Motion](core-motion.md#window)
5. กด **Train**

!!! intel "{{ mac.intel }} · Xcode 26"
    Train บน {{ mac.intel }} ช้ากว่า เริ่มจาก 3 ท่า ท่าละไม่กี่ไฟล์ก่อน ได้ผลแล้วค่อยเพิ่มข้อมูล

### 4. ดูผลและทดสอบ

| แท็บ | ดูอะไร |
|---|---|
| **Evaluation** | ความแม่นยำบนข้อมูล training และ validation ถ้า training สูงแต่ validation ต่ำมาก แปลว่า model จำข้อมูลแทนที่จะเรียนรู้ ให้อัดข้อมูลเพิ่มจากหลายคน |
| **Preview** | ลากไฟล์ที่ไม่ได้ใช้ train มาทดสอบ ดูว่าทายถูกไหม |

ดูด้วยว่าท่าไหนถูกทายผิดเป็นท่าไหนบ่อย ถ้าสองท่าสับสนกันตลอด ลองเปลี่ยนท่าให้ต่างกันมากขึ้น

### 5. Export

แท็บ **Output** › **Get** จะได้ไฟล์ `.mlmodel` ตั้งชื่อให้สื่อความหมาย เช่น `GestureClassifier.mlmodel` เพราะ Xcode จะใช้ชื่อไฟล์เป็นชื่อ class ต่อไปดูวิธีใช้ใน app ที่ [Core ML](core-ml.md)

## Sound Classifier

ใช้เมื่อต้องการจดจำเสียงที่ [classifier ในตัว](sound.md) ไม่รู้จัก ขั้นตอนเหมือน Activity Classifier แต่ใช้ไฟล์เสียง

1. **อัดเสียง** แต่ละแบบหลายๆ ครั้ง ด้วย Voice Memos หรือ recorder app ได้เลย คลิปละไม่กี่วินาที
2. **จัด folder ตามชื่อเสียง** และ **ใส่ folder `background`** ที่เป็นเสียงห้องเงียบหรือเสียงทั่วไป model จะได้แยกได้ว่าตอนไหนไม่มีเสียงที่สนใจ

    ```text
    SoundData/
    ├── cough/
    ├── sneeze/
    └── background/
    ```

3. Create ML › **Sound Classifier** › ลาก folder มาวาง › **Train**
4. แท็บ **Preview** ทดสอบสดๆ จากไมโครโฟนของ Mac ได้
5. **Get** ไฟล์ model แล้วใช้กับโค้ดในหน้า [Sound recognition](sound.md#model-train)

## ทำให้ model ดีขึ้น

- **ข้อมูลหลากหลาย ดีกว่าข้อมูลเยอะ**: อัดจากหลายคน หลายสถานที่ หลายแบบการจับ
- **จำนวนตัวอย่างใกล้เคียงกันทุกป้าย**: ถ้าท่าหนึ่งมี 20 ไฟล์ อีกท่ามี 3 ไฟล์ model จะเอนเอียงไปทางท่าที่มีเยอะ
- **ทดสอบบนข้อมูลใหม่เสมอ**: ข้อมูลที่ใช้ train ทายถูกเกือบทุกครั้งอยู่แล้ว ไม่ได้บอกว่าใช้จริงได้ดี

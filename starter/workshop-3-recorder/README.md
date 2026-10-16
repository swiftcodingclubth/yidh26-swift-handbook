# Workshop 3: Motion Recorder

App อัดข้อมูลท่าทางสำหรับ train Activity Classifier ใน Create ML · iOS 26 · ไม่มี dependency ภายนอก · เปิดได้ทั้ง Xcode 26 และ 27

ใช้ตามขั้นตอนในหน้า **Create ML** ของ handbook เป็นเครื่องมือ ไม่ใช่เนื้อหาที่ต้องเรียน ไม่ต้องอ่านโค้ดก็ได้

## เริ่มใช้งาน

1. เปิด `MotionRecorder.xcodeproj`
2. เลือก target **MotionRecorder** → **Signing & Capabilities** → เลือก **Team** ของตัวเอง
3. เลือก iPad เป็น run destination แล้วกด Run (Simulator ไม่มี sensor การเคลื่อนไหว ต้องใช้ iPad จริง)

## อัดข้อมูล

1. เลือกท่า (`shake`, `tilt`, `circle`, `idle`) หรือพิมพ์ชื่อเอง ชื่อนี้คือชื่อที่ model จะตอบกลับมา
2. กด **อัดท่า** นับถอยหลัง 3 วินาที แล้วทำท่าซ้ำ ๆ
3. กด **หยุดและบันทึก** ได้ไฟล์ CSV หนึ่งไฟล์ เช่น `shake-01.csv`
4. ทำท่าละ 5–10 รอบ และอัดท่า `idle` (ถือนิ่ง ๆ) ด้วย

## ส่งมาที่ Mac

กด **ส่ง MotionData.zip** แล้ว AirDrop มาที่ Mac ดับเบิลคลิก zip ใน Downloads จะได้ folder แยกตามชื่อท่า ลากไปวางใน Create ML ได้เลย

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

หรือเปิด app **Files** › On My iPad › Motion Recorder แล้ว copy folder `MotionData` ไปได้เหมือนกัน

## ไฟล์ CSV

บันทึกที่ 50 Hz (50 ค่าต่อวินาที) เท่ากับ `startMotionUpdates` ในหน้า Core Motion

| Column | ค่าจาก `CMDeviceMotion` |
|---|---|
| `timestamp` | วินาทีนับจากเริ่มอัด (ไม่ต้องเลือกเป็น feature ตอน train) |
| `accelX`, `accelY`, `accelZ` | `userAcceleration` (g) |
| `rotationX`, `rotationY`, `rotationZ` | `rotationRate` (rad/s) |

ชื่อ column ตรงกับตัวอย่าง `GestureClassifierInput` ในหน้า Core ML

## ไฟล์ใน project

| ไฟล์ | มีอะไร |
|---|---|
| `Motion.swift` | `startMotionUpdates`, `stopMotionUpdates` จากหน้า Core Motion |
| `Recorder.swift` | เก็บค่าระหว่างอัด เขียน CSV และสร้าง `MotionData.zip` |
| `RecordView.swift` | หน้าจอ |

# Core Motion

**Core Motion** คือ framework ที่อ่านข้อมูลการเคลื่อนไหวของเครื่อง เช่น เครื่องถูกเขย่า เอียง หมุน หรือกำลังขึ้นบันได ข้อมูลนี้เป็นพื้นฐานของ app ออกกำลังกาย เกม และการจดจำท่าทาง ใช้ได้ทั้ง Xcode 26 และ 27

## Sensor มีอะไรบ้าง

| Sensor | วัดอะไร |
|---|---|
| **Accelerometer** | ความเร่งของเครื่อง รวมแรงโน้มถ่วง |
| **Gyroscope** | ความเร็วในการหมุนรอบแกน x, y, z |
| **Magnetometer** | สนามแม่เหล็ก ใช้หาทิศ |
| **Barometer** | ความกดอากาศ ใช้หาความสูงที่เปลี่ยนไป |

ค่าดิบจาก sensor แต่ละตัวมี noise และปนกันอยู่ เช่น accelerometer วัดได้ทั้งแรงโน้มถ่วงและการขยับมือรวมกัน Core Motion จึงมี **device motion** ที่รวมข้อมูลหลาย sensor แล้วแยกออกมาให้ใช้ง่าย แนะนำให้ใช้ตัวนี้

| ค่าใน `CMDeviceMotion` | ความหมาย | ใช้ทำอะไร |
|---|---|---|
| `userAcceleration` | ความเร่งที่ผู้ใช้ทำ (ตัดแรงโน้มถ่วงออกแล้ว) | ตรวจจับการเขย่า การกระแทก การเหวี่ยง |
| `gravity` | ทิศของแรงโน้มถ่วงเทียบกับเครื่อง | รู้ว่าเครื่องตั้ง นอน หรือคว่ำอยู่ |
| `rotationRate` | ความเร็วการหมุน (ปรับเทียบแล้ว) | ตรวจจับการบิด การหมุนข้อมือ |
| `attitude` | มุมของเครื่อง: `pitch`, `roll`, `yaw` | ตรวจจับการเอียง ใช้เป็นจอยควบคุม |

## เลือก sampling rate

Sampling rate คือจำนวนครั้งที่อ่านค่าต่อวินาที ยิ่งสูงยิ่งเห็นการเคลื่อนไหวละเอียด แต่กินแบตเตอรี่และ CPU มากขึ้น

| Rate | `deviceMotionUpdateInterval` | เหมาะกับ |
|---|---|---|
| 10 Hz | `1.0 / 10.0` | ท่าช้าๆ เช่น เอียงเครื่อง, ท่าทางของร่างกาย |
| 50 Hz | `1.0 / 50.0` | การจดจำท่าทางทั่วไป เช่น Motion Coach |
| 100 Hz | `1.0 / 100.0` | การเคลื่อนไหวเร็วมาก เช่น เหวี่ยงไม้ ตีลูก |

!!! warning "ใช้ rate เดียวกันตอนอัดและตอนใช้งาน"
    Model ที่ train จากข้อมูล 50 Hz ต้องได้ข้อมูล 50 Hz ตอนใช้งานด้วย ถ้า rate ต่างกัน ท่าเดียวกันจะดูเร็วหรือช้าไปในสายตา model และทายผิด

## Barometer

`CMAltimeter` บอกความสูงที่เปลี่ยนไปจากตอนเริ่มวัด หน่วยเป็นเมตร ใช้รู้ว่าผู้ใช้ขึ้นหรือลงชั้น ไม่ได้บอกความสูงจากระดับน้ำทะเล

```swift
let altimeter = CMAltimeter()

func startAltitudeUpdates(onChange: @escaping (Double) -> Void) {
    guard CMAltimeter.isRelativeAltitudeAvailable() else { return }
    altimeter.startRelativeAltitudeUpdates(to: .main) { data, _ in
        if let data { onChange(data.relativeAltitude.doubleValue) }   // เมตร
    }
}
```

ชั้นหนึ่งสูงประมาณ 3 เมตร ค่าเปลี่ยนเกิน ±3 จึงแปลว่าขึ้นหรือลงหนึ่งชั้น

## Permission

| ใช้อะไร | ต้องขอ permission ไหม |
|---|---|
| `CMMotionManager` (accelerometer, gyroscope, device motion) | ไม่ต้อง |
| `CMAltimeter`, `CMPedometer`, `CMMotionActivityManager` | ต้องใส่ `NSMotionUsageDescription` ใน Info.plist |

```text
NSMotionUsageDescription
    "ใช้ข้อมูลการเคลื่อนไหวเพื่อนับการขึ้นลงชั้น"
```

ข้อความนี้จะแสดงให้ผู้ใช้เห็นตอนขออนุญาต เขียนให้บอกชัดว่าจะเอาข้อมูลไปทำอะไร ถ้าไม่ใส่ app จะ crash เมื่อเรียก API เหล่านี้

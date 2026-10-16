# Core Motion

**Core Motion** คือ framework ที่อ่านข้อมูลการเคลื่อนไหวของเครื่อง เช่น เครื่องถูกเขย่า เอียง หมุน หรือกำลังขึ้นบันได ข้อมูลนี้เป็นพื้นฐานของ app ออกกำลังกาย เกม และการจดจำท่าทาง ใช้ได้ทั้ง Xcode 26 และ 27

## Sensor มีอะไรบ้าง

| Sensor | วัดอะไร | หน่วย |
|---|---|---|
| **Accelerometer** | ความเร่งของเครื่อง รวมแรงโน้มถ่วง | g (1 g ≈ 9.8 m/s²) |
| **Gyroscope** | ความเร็วในการหมุนรอบแกน x, y, z | radian ต่อวินาที |
| **Magnetometer** | สนามแม่เหล็ก ใช้หาทิศ | microtesla |
| **Barometer** | ความกดอากาศ ใช้หาความสูงที่เปลี่ยนไป | kPa, เมตร |

ค่าดิบจาก sensor แต่ละตัวมี noise และปนกันอยู่ เช่น accelerometer วัดได้ทั้งแรงโน้มถ่วงและการขยับมือรวมกัน Core Motion จึงมี **device motion** ที่รวมข้อมูลหลาย sensor แล้วแยกออกมาให้ใช้ง่าย แนะนำให้ใช้ตัวนี้

| ค่าใน `CMDeviceMotion` | ความหมาย | ใช้ทำอะไร |
|---|---|---|
| `userAcceleration` | ความเร่งที่ผู้ใช้ทำ (ตัดแรงโน้มถ่วงออกแล้ว) | ตรวจจับการเขย่า การกระแทก การเหวี่ยง |
| `gravity` | ทิศของแรงโน้มถ่วงเทียบกับเครื่อง | รู้ว่าเครื่องตั้ง นอน หรือคว่ำอยู่ |
| `rotationRate` | ความเร็วการหมุน (ปรับเทียบแล้ว) | ตรวจจับการบิด การหมุนข้อมือ |
| `attitude` | มุมของเครื่อง: `pitch`, `roll`, `yaw` ([อธิบาย](#attitude)) | ตรวจจับการเอียง ใช้เป็นจอยควบคุม |

![แกน x, y, z ของอุปกรณ์ และ sensor ที่ Core Motion ใช้: accelerometer, gyroscope, magnetometer, barometer](images/core-motion.jpg)
*ภาพจาก [WWDC23 session 10179](https://developer.apple.com/videos/play/wwdc2023/10179/)*

## อ่านข้อมูลการเคลื่อนไหว

* สร้าง `CMMotionManager` **ตัวเดียว** ทั้ง app เพื่อ Check ว่าเครื่องรองรับ
* ตั้ง sampling rate แล้วเริ่มรับข้อมูล Core Motion จะเรียก closure ทุกครั้งที่มีค่าใหม่

```swift
import CoreMotion

let motion = CMMotionManager()

func startMotionUpdates(onSample: @escaping (CMDeviceMotion) -> Void) {
    guard motion.isDeviceMotionAvailable else { return }   // Simulator ไม่มี sensor
    motion.deviceMotionUpdateInterval = 1.0 / 50.0         // 50 ครั้งต่อวินาที (50 Hz)
    motion.startDeviceMotionUpdates(to: .main) { data, _ in
        if let data { onSample(data) }
    }
}

func stopMotionUpdates() {
    motion.stopDeviceMotionUpdates()
}
```

ตัวอย่างการใช้ใน SwiftUI: เริ่มเมื่อหน้าจอแสดง และ **หยุดเมื่อออกจากหน้าจอ** เพราะ sensor ที่เปิดค้างไว้กินแบตเตอรี่ตลอดเวลา

```swift
struct MotionView: View {
    @State private var x = 0.0

    var body: some View {
        Text("แรงเหวี่ยงแกน x: \(x, specifier: "%.2f") g")
            .onAppear {
                startMotionUpdates { data in
                    x = data.userAcceleration.x
                }
            }
            .onDisappear { stopMotionUpdates() }
    }
}
```

!!! note "ต้องทดสอบบน iPad จริง"
    Simulator ไม่มี sensor การเคลื่อนไหว `isDeviceMotionAvailable` จะเป็น `false`

## มุมของเครื่อง: roll, pitch, yaw { #attitude }

`attitude` บอกว่า **ตอนนี้เครื่องเอียงอยู่แค่ไหน** แยกเป็น 3 มุม ขยับได้ 3 แบบ

| มุม | ลองทำกับ iPad ที่วางราบบนโต๊ะ (แนวตั้ง จอหันขึ้น) | หมุนรอบแกน | ช่วงค่า |
|---|---|---|---|
| **pitch** | ยกขอบบนขึ้น หรือกดขอบบนลง | x | -90° ถึง 90° |
| **roll** | ยกขอบขวาหรือขอบซ้ายขึ้น | y | -180° ถึง 180° |
| **yaw** | หมุนเครื่องบนโต๊ะ โดยไม่ยกขึ้น | z | -180° ถึง 180° |

### Radian กับองศา

Core Motion ให้มุมเป็น **radian** ไม่ใช่องศา แปลงเป็นองศาด้วย `radian * 180 / .pi`

| Radian | องศา | ความหมาย |
|---|---|---|
| `0` | 0° | วางราบ ไม่เอียง |
| `.pi / 4` | 45° | เอียงครึ่งทาง (ค่านี้ใช้ใน [`detectGesture`](#gesture)) |
| `.pi / 2` | 90° | ตั้งขึ้นตรง |

### ดูค่าทั้ง 3 มุม

ใช้ `startMotionUpdates` เหมือน `MotionView` แค่เปลี่ยนไปอ่าน `data.attitude` แล้วลองขยับเครื่องตามตารางด้านบนดูว่ามุมไหนเปลี่ยน

```swift
struct AttitudeView: View {
    @State private var pitch = 0.0
    @State private var roll = 0.0
    @State private var yaw = 0.0

    var body: some View {
        VStack {
            Text("pitch: \(pitch, specifier: "%.0f")°")
            Text("roll: \(roll, specifier: "%.0f")°")
            Text("yaw: \(yaw, specifier: "%.0f")°")
        }
        .onAppear {
            startMotionUpdates { data in
                pitch = data.attitude.pitch * 180 / .pi  // radian → องศา
                roll = data.attitude.roll * 180 / .pi
                yaw = data.attitude.yaw * 180 / .pi
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}
```

### เอียงหรือไม่เอียง?

วาง iPad ราบบนโต๊ะหรือชั้นวาง ถ้า roll ใกล้ 0° แปลว่าพื้นไม่เอียงซ้ายขวา เส้นบนจอหมุนตามมุมเอียง และเปลี่ยนเป็นสีเขียวเมื่อตรงแล้ว

```swift
struct LevelView: View {
    @State private var roll = 0.0  // มุมเอียงซ้าย-ขวา (radian)

    var body: some View {
        let degrees = roll * 180 / .pi
        let isLevel = abs(degrees) < 1  // เอียงไม่ถึง 1° ถือว่าตรง

        VStack(spacing: 40) {
            Text(String(format: "%.1f°", degrees))
                .font(.system(size: 80, weight: .bold))

            Capsule() // เส้นหมุนตามมุมเอียงของเครื่อง
                .fill(isLevel ? .green : .orange)
                .frame(width: 300, height: 12)
                .rotationEffect(.radians(-roll))

            Text(isLevel ? "ตรงแล้ว" : "ยังเอียงอยู่")
        }
        .onAppear {
            startMotionUpdates { data in
                roll = data.attitude.roll
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}
```

ลองเพิ่มเอง: อ่าน `pitch` ด้วย แล้วเช็กว่าโต๊ะเอียงหน้าหลังไหม

!!! warning "yaw ไม่ใช่ทิศเหนือ"
    yaw = 0° คือทิศที่เครื่องหันอยู่ **ตอนเริ่ม** `startMotionUpdates` ไม่ใช่ทิศเหนือ ถ้าต้องการทิศจริงแบบเข็มทิศต้องใช้ magnetometer ซึ่งไม่อยู่ใน workshop นี้

## เลือก sampling rate

Sampling rate คือจำนวนครั้งที่อ่านค่าต่อวินาที ยิ่งสูงยิ่งเห็นการเคลื่อนไหวละเอียด แต่กินแบตเตอรี่และ CPU มากขึ้น

| Rate | `deviceMotionUpdateInterval` | เหมาะกับ |
|---|---|---|
| 10 Hz | `1.0 / 10.0` | ท่าช้า ๆ เช่น เอียงเครื่อง, ท่าทางของร่างกาย |
| 50 Hz | `1.0 / 50.0` | การเคลื่อนไหวทั่วไป เช่น ตรวจจับการเขย่า, เกมเอียงเครื่อง |
| 100 Hz | `1.0 / 100.0` | การเคลื่อนไหวเร็วมาก เช่น เหวี่ยงไม้ ตีลูก |

## ตรวจจับท่าแบบง่ายโดยไม่ใช้ ML { #gesture }

ท่าง่าย ๆ ไม่ต้อง train model ก็ได้ ใช้ค่าจาก device motion ตั้งเงื่อนไขเอง

```swift
func detectGesture(_ data: CMDeviceMotion) -> String? {
    let a = data.userAcceleration
    let force = (a.x * a.x + a.y * a.y + a.z * a.z).squareRoot()

    if force > 2.0 { return "เขย่า" } // แรงลัพธ์เกิน 2 g
    if abs(data.attitude.roll) > .pi / 4 { return "เอียง" } // เอียงเกิน 45°
    return nil
}
```

ปรับตัวเลข `2.0` และ `.pi / 4` ด้วยการลองจริง: print ค่าออกมาขณะทำท่า แล้วดูว่าท่าที่ต้องการให้ค่าประมาณเท่าไหร่


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

!!! tip "Activity ในตัว ไม่ต้อง train"
    ถ้าแค่อยากรู้ว่าผู้ใช้ เดิน วิ่ง ปั่นจักรยาน หรืออยู่ในรถ ใช้ `CMMotionActivityManager` และนับก้าวด้วย `CMPedometer` ได้เลย ไม่ต้อง train model เอง

!!! tip "ใช้ใน app ของทีม"
    โค้ดในหน้านี้อยู่ใน `SensorParts/Motion.swift` ของ [starter project](add-to-your-app.md#get-starter) copy ไปใช้ได้เลย ดูขั้นตอนที่[ใส่ใน app ของทีม](add-to-your-app.md)

# Hand pose

**Hand pose** คือการให้ Vision หาตำแหน่งข้อนิ้วมือ **21 จุด** จากภาพ เช่น ปลายนิ้วชี้อยู่ตรงไหน ข้อมืออยู่ตรงไหน Vision ไม่บอกว่ามือทำท่าอะไร เราเป็นคนตีความจากตำแหน่งจุดเอง ใช้ได้ทั้ง Xcode 26 และ 27

ใช้ทำอะไรได้: เกมเป่ายิ้งฉุบ, นับนิ้วสอนเลขเด็ก, สั่ง app โดยไม่ต้องแตะจอ (เช่น ตอนมือเปื้อนขณะทำอาหาร), วาดในอากาศด้วยนิ้วชี้

ข้อจำกัด:

- **Run บน iPad จริงเท่านั้น** หน้านี้ใช้กล้องสด และ Simulator ไม่มีกล้อง
- **Vision บอกแค่ตำแหน่งจุด ไม่บอกชื่อท่า** การตีความเป็นท่าต้องเขียน logic เอง หรือ train model ด้วย [Create ML](../workshop-3/create-ml.md)
- **ต้องเห็นมือชัด** แสงน้อย ย้อนแสง มือบังกัน หรือมืออยู่นอกเฟรม ทำให้จุดหายหรือเพี้ยน ระยะที่ดีคือประมาณ 30–60 cm จากกล้อง
- **ได้ตำแหน่ง 2 มิติ** รู้ว่านิ้วอยู่ตรงไหนบนภาพ แต่ไม่รู้ว่าใกล้หรือไกลกล้องแค่ไหน
- **กินแบตเตอรี่และทำให้เครื่องร้อน** เพราะประมวลผลกล้องตลอดเวลา ต้องหยุดกล้องเมื่อออกจากหน้าจอ

## จุดบนมือ { #joints }

| กลุ่ม | จุด (`HumanHandPoseObservation.JointName`) |
|---|---|
| ข้อมือ | `.wrist` |
| นิ้วโป้ง | `.thumbCMC` `.thumbMP` `.thumbIP` `.thumbTip` |
| นิ้วชี้ | `.indexMCP` `.indexPIP` `.indexDIP` `.indexTip` |
| นิ้วกลาง / นาง / ก้อย | `.middle…` `.ring…` `.little…` (MCP, PIP, DIP, Tip เหมือนนิ้วชี้) |

`MCP` = โคนนิ้ว, `PIP` = ข้อกลาง, `DIP` = ข้อใกล้ปลาย, `Tip` = ปลายนิ้ว แต่ละจุดมี `location` (ตำแหน่งแบบ 0–1 ของภาพ) และ `confidence` (ความมั่นใจ 0–1)

## Setup

ต้องใช้กล้องสด จึงต้องมี `NSCameraUsageDescription` ใน Info.plist เหมือน [VisionKit](visionkit.md#setup) ส่วนกล้องใช้ `CameraView` จาก starter project ซึ่งขอสิทธิ์กล้องเอง และส่งภาพมาให้ทีละ frame (`CVPixelBuffer`) ที่หมุนให้ตั้งตรงแล้ว

## 1. หามือในภาพ { #detect }

ใช้ pattern เดิม: สร้าง request → `perform(on:)` → อ่าน observation ตั้ง `maximumHandCount = 1` ถ้าสนใจแค่มือเดียว จะเร็วขึ้น

```swift
import Vision

func findHand(in frame: CVPixelBuffer) async -> HumanHandPoseObservation? {
    var request = DetectHumanHandPoseRequest()
    request.maximumHandCount = 1
    return try? await request.perform(on: CIImage(cvPixelBuffer: frame)).first
}
```

ห่อ frame เป็น `CIImage` ก่อนส่ง เพราะ `CVPixelBuffer` ส่งข้าม thread ตรงๆ ไม่ได้ใน Swift 6 วิธีนี้ใช้ได้ทั้ง Swift 5 และ 6

ถ้าไม่เจอมือจะได้ `nil` กล้องส่งภาพมาประมาณ 30 frame ต่อวินาที ถ้า frame ก่อนหน้ายังทำไม่เสร็จให้ข้ามไป ไม่ต้องต่อคิว (ดูหัวข้อ 2)

## 2. วาดจุดนิ้วบนจอ { #draw }

ทำให้เห็นก่อนว่า Vision เจอมือ แล้วค่อยเขียน logic ตำแหน่งของ Vision มีจุด (0, 0) อยู่ **มุมล่างซ้าย** แต่ SwiftUI อยู่ **มุมบนซ้าย** จึงต้องกลับแกน y

```swift
@Observable @MainActor
final class HandModel {
    var points: [CGPoint] = []
    private var isBusy = false

    func handle(_ frame: CVPixelBuffer) {
        guard !isBusy else { return }   // frame เก่ายังไม่เสร็จ ข้ามไปก่อน
        isBusy = true
        Task {
            defer { isBusy = false }
            guard let hand = await findHand(in: frame) else { points = []; return }
            points = hand.allJoints().values
                .filter { $0.confidence > 0.3 }
                .map { CGPoint(x: $0.location.x, y: 1 - $0.location.y) }  // กลับแกน y
        }
    }
}
```

`CameraView` รับ overlay เป็น closure ท้าย แล้ววาดทับในกรอบเดียวกับภาพจากกล้องพอดี ตำแหน่ง 0–1 จึงตรงกับภาพ

```swift
import AVFoundation
import SwiftUI

struct HandScreen: View {
    @State private var model = HandModel()

    var body: some View {
        CameraView(position: .front, onFrame: model.handle) {
            HandPointsOverlay(points: model.points)
        }
    }
}

struct HandPointsOverlay: View {
    var points: [CGPoint]

    var body: some View {
        GeometryReader { geo in
            ForEach(points.indices, id: \.self) { i in
                Circle().fill(.yellow).frame(width: 14, height: 14)
                    .position(x: points[i].x * geo.size.width, y: points[i].y * geo.size.height)
            }
        }
    }
}
```

ต้อง `import AVFoundation` เพราะ `.front` มาจาก AVFoundation ส่วนกล้องหน้า `CameraView` กลับภาพแบบกระจกให้ทั้งภาพบนจอและ frame ที่ส่งให้ Vision จุดจึงตรงกับมือ ทั้งตอนถือแนวตั้งและแนวนอน ถ้าเขียนกล้องเอง ต้องกลับแกน x เอง (`1 - x`)

## 3. แปลงเป็นท่า { #gesture }

หลักง่ายๆ: **นิ้วเหยียด = ปลายนิ้วอยู่ไกลข้อมือมากกว่าข้อกลางนิ้ว** นับแค่ 4 นิ้ว (ไม่นับนิ้วโป้ง เพราะนิ้วโป้งงอไปด้านข้าง ตัดสินยากกว่า)

```swift
extension HumanHandPoseObservation {
    var extendedFingerCount: Int {
        guard let wrist = joint(for: .wrist) else { return 0 }
        let fingers: [(tip: JointName, pip: JointName)] = [
            (.indexTip, .indexPIP), (.middleTip, .middlePIP),
            (.ringTip, .ringPIP), (.littleTip, .littlePIP),
        ]
        return fingers.filter { finger in
            guard let tip = joint(for: finger.tip), let pip = joint(for: finger.pip),
                  tip.confidence > 0.3, pip.confidence > 0.3 else { return false }
            return tip.distance(to: wrist) > pip.distance(to: wrist)
        }.count
    }
}

enum HandSign: String {
    case rock = "✊", scissors = "✌️", paper = "✋", unknown = "❓"

    init(fingers: Int) {
        switch fingers {
        case 0: self = .rock
        case 2: self = .scissors
        case 4: self = .paper
        default: self = .unknown
        }
    }
}
```

ใน `HandModel` เพิ่ม `var sign: HandSign = .unknown` แล้วตั้ง `sign = HandSign(fingers: hand.extendedFingerCount)` ต่อจากบรรทัด `points = …` แสดงด้วย `Text(model.sign.rawValue).font(.system(size: 120))`

ท่าของทีมเองใช้หลักเดียวกัน เช่น "ชี้ขึ้น" = นิ้วชี้เหยียดนิ้วเดียวและ `indexTip.y` สูงกว่าข้อมือ หรือ "จีบนิ้ว" = `thumbTip` กับ `indexTip` ใกล้กันมาก

## 4. ทำให้ผลนิ่ง { #smoothing }

ผลจะกระพริบสลับไปมาตอนเปลี่ยนท่า ถ้าจะใช้ท่าสั่ง action ให้รอจนได้ท่าเดิมติดกันหลาย frame ก่อน

```swift
private var lastSign: HandSign = .unknown
private var sameCount = 0

func update(with newSign: HandSign) {
    sameCount = (newSign == lastSign) ? sameCount + 1 : 0
    lastSign = newSign
    if sameCount >= 5 { sign = newSign }   // ประมาณ 1/6 วินาทีที่ 30 fps
}
```

เพิ่มเลข 5 ถ้ายังกระพริบ ลดถ้ารู้สึกว่าตอบสนองช้า

## ภารกิจเสริม { #extra }

สำหรับคนที่ทำเสร็จก่อน หรือยังไม่อยากใส่ใน project ของทีม

1. **เกมเป่ายิ้งฉุบ**: ให้ iPad สุ่มท่าของตัวเอง นับถอยหลัง 3-2-1 แล้วตัดสินแพ้ชนะ
2. **นับนิ้วรวมนิ้วโป้ง**: นิ้วโป้งเหยียดเมื่อ `thumbTip` อยู่ไกลจาก `indexMCP` มากกว่า `thumbIP`
3. **วาดในอากาศ**: เก็บตำแหน่ง `indexTip` ทุก frame แล้ววาดเส้นด้วย `Path`
4. **สองมือ**: ตั้ง `maximumHandCount = 2` แล้วดู `chirality` ว่าเป็นมือซ้ายหรือขวา

## ปัญหาที่เจอบ่อย

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| ไม่มีจุดขึ้นเลย | แสงน้อย, ย้อนแสง หรือมืออยู่นอกเฟรม | หันหน้าเข้าหาแสง ให้เห็นมือทั้งมือ ห่างกล้องประมาณ 30–60 cm |
| จุดอยู่คนละที่กับมือ | ลืมกลับแกน y หรือกล้องหน้าเป็นภาพกระจก | `y: 1 - location.y` และลอง `x: 1 - location.x` |
| ท่ากรรไกรขึ้นเป็น ❓ บ่อย | นิ้วนางหรือก้อยงอไม่สุด Vision เลยนับเป็น 3 | ให้ทำท่าชัดๆ หรือเช็กเฉพาะนิ้วชี้กับนิ้วกลาง |
| App กระตุก, iPad ร้อน | ประมวลผลทุก frame ต่อคิว | ใช้ `isBusy` ข้าม frame และหยุดกล้องเมื่อออกจากหน้าจอ |

## ใช้ร่วมกับ

- [Create ML](../workshop-3/create-ml.md): ถ้าท่าซับซ้อนเกินจะเขียน `if` เอง ให้ train **Hand Pose Classifier** จากรูปท่ามือ
- [Core Motion](../workshop-3/core-motion.md): ใช้คู่กับการเอียงเครื่อง เช่น เกมที่ใช้ทั้งท่ามือและการเอียง

## ไปต่อ

- **Body pose**: `DetectHumanBodyPoseRequest` ใช้ pattern เดียวกัน ได้ `HumanBodyPoseObservation` 19 จุด เช่น ไหล่ ศอก สะโพก เข่า ใช้นับ squat หรือเช็กท่าออกกำลังกายได้ ตั้ง `detectsHands = true` เพื่อให้ได้จุดมือมาด้วย
- **Hand pose model ใหม่ใน iOS 26**: Apple เปลี่ยน model ให้เล็ก เร็ว และแม่นขึ้น ยังได้ 21 จุด แต่ตำแหน่งจุดต่างจากเดิมเล็กน้อย ถ้าเคย train classifier ด้วยข้อมูลจาก iOS เก่า ให้ train ใหม่

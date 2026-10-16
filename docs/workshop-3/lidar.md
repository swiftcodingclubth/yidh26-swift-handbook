# LiDAR

**LiDAR** (Light Detection and Ranging) คือ sensor ที่ยิงแสงเลเซอร์ที่มองไม่เห็นออกไป แล้ววัดเวลาที่แสงสะท้อนกลับมา จึงรู้ว่าแต่ละจุดในภาพอยู่ห่างจากเครื่องกี่เมตร ทำงานได้ดีแม้ในที่แสงน้อย และวัดได้ไกลประมาณ 5 เมตร ใช้ได้ทั้ง Xcode 26 และ 27

ใช้ทำอะไรได้: วัดขนาดสิ่งของ, วัดระยะห่าง, เช็กว่าเฟอร์นิเจอร์วางในห้องได้พอดีไหม, เตือนผู้พิการทางสายตาเมื่อมีสิ่งกีดขวางข้างหน้า

!!! warning "มีเฉพาะ iPad Pro และ iPhone Pro"
    iPad Air, iPad mini, iPad รุ่นธรรมดา และ iPhone รุ่นที่ไม่ใช่ Pro **ไม่มี LiDAR** ดูรุ่น iPad ของทีมได้จาก Team card ถ้าไม่มี ให้ทำ track Core Motion หรือ Sound แทน และเขียน app ให้เช็กก่อนใช้เสมอ เพื่อไม่ให้ crash บนเครื่องที่ไม่มี

## ข้อมูลความลึกคืออะไร

ARKit ส่งข้อมูลความลึกมาพร้อมภาพจากกล้องทุก frame ในรูปแบบ **depth map**: ภาพขนาดเล็ก (256 × 192 จุด) ที่แต่ละจุดเก็บระยะห่างเป็นเมตรแทนสี

| ข้อมูลใน `ARFrame.sceneDepth` | ความหมาย |
|---|---|
| `depthMap` | ระยะของแต่ละจุดเป็นเมตร (`Float32`) |
| `confidenceMap` | ความน่าเชื่อถือของแต่ละจุด: `low`, `medium`, `high` |

ขอบวัตถุ พื้นผิวมันวาว และกระจก มักได้ความน่าเชื่อถือต่ำ ควรใช้เฉพาะจุดที่น่าเชื่อถือ

## Permission

LiDAR ทำงานผ่านกล้อง จึงต้องขอสิทธิ์กล้องใน Info.plist

```text
NSCameraUsageDescription
    "ใช้กล้องและ LiDAR เพื่อวัดระยะห่างของสิ่งของ"
```

## เช็กว่าเครื่องมี LiDAR

```swift
import ARKit

let hasLiDAR = ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth)
```

ใช้ค่านี้ตัดสินว่าจะแสดง feature วัดระยะ หรือแสดงข้อความว่าเครื่องนี้ไม่รองรับ

## วัดระยะที่จุดกลางจอ

เริ่ม `ARSession` พร้อมเปิด `.sceneDepth` แล้วอ่านค่ากลาง depth map ทุก frame ซึ่งก็คือระยะของสิ่งที่อยู่ตรงกลางภาพ

```swift
import ARKit

final class DepthReader: NSObject, ARSessionDelegate {
    let session = ARSession()
    var onDistance: (Float) -> Void = { _ in }

    func start() {
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) else { return }
        let config = ARWorldTrackingConfiguration()
        config.frameSemantics = .sceneDepth
        session.delegate = self
        session.run(config)
    }

    func stop() {
        session.pause()
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let depthMap = frame.sceneDepth?.depthMap else { return }

        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }

        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
        guard let base = CVPixelBufferGetBaseAddress(depthMap) else { return }

        // แถวกลาง แล้วอ่านจุดกลางของแถว
        let row = base.advanced(by: (height / 2) * bytesPerRow)
            .assumingMemoryBound(to: Float32.self)
        onDistance(row[width / 2])   // เมตร
    }
}
```

`didUpdate` ถูกเรียกประมาณ 60 ครั้งต่อวินาที ถ้าจะอัปเดต UI ไม่จำเป็นต้องทุก frame อัปเดตแค่ไม่กี่ครั้งต่อวินาทีก็พอ และเรียก `stop()` เมื่อออกจากหน้าจอ เพราะกล้องกับ LiDAR กินแบตเตอรี่มาก

!!! tip "อยากได้ค่าที่นิ่งกว่า"
    ใช้ `.smoothedSceneDepth` แทน `.sceneDepth` (และ `frame.smoothedSceneDepth`) ARKit จะเฉลี่ยค่าจากหลาย frame ให้ ตัวเลขจะกระโดดน้อยลง แต่ตอบสนองช้าลงเล็กน้อย

## ใช้ร่วมกับ

- ส่งระยะที่วัดได้ให้ [Core AI](core-ai.md) หรือ [Foundation Models](../workshop-2/foundation-models.md) ช่วยอธิบาย เช่น "โต๊ะกว้าง 1.2 เมตร ช่องว่างกว้าง 1.0 เมตร วางได้ไหม"
- ใช้คู่กับ [Core Motion](core-motion.md): รู้ทั้งระยะและมุมเอียงของเครื่อง

!!! tip "ใช้ใน app ของทีม"
    โค้ดในหน้านี้อยู่ใน `SensorParts/Lidar.swift` ของ [starter project](add-to-your-app.md#get-starter) copy ไปใช้ได้เลย ดูขั้นตอนที่[ใส่ใน app ของทีม](add-to-your-app.md)

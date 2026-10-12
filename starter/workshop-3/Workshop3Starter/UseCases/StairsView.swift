import CoreMotion
import SwiftUI

/// Use case: app ออกกำลังกาย นับว่าเดินขึ้นบันไดไปกี่ชั้น
/// ชั้นหนึ่งสูงประมาณ 3 เมตร ลองถือ iPad เดินขึ้นหรือลงบันไดดู
/// ต้องมี NSMotionUsageDescription ใน Info.plist (project นี้ตั้งไว้แล้ว)
struct StairsView: View {
    @State private var meters = 0.0

    var body: some View {
        let floors = Int(meters / 3)

        VStack(spacing: 24) {
            Text("\(floors) ชั้น")
                .font(.system(size: 80, weight: .bold))
            Text(String(format: "ความสูงเปลี่ยนไป %+.1f เมตร", meters))
                .font(.title2)
                .monospacedDigit()
        }
        .navigationTitle("นับชั้น")
        .onAppear {
            startAltitudeUpdates { value in
                meters = value
            }
        }
        .onDisappear { stopAltitudeUpdates() }
    }
}

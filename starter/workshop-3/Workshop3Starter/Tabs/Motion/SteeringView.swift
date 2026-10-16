import CoreMotion
import SwiftUI

/// Use case: เกมแข่งรถ ถือเครื่องราบตรงหน้าแล้วเอียงซ้ายขวาเหมือนพวงมาลัย
/// attitude.roll บอกว่าเลี้ยวไปทางไหนและมากแค่ไหน
/// rotationRate.y บอกว่าหักเร็วแค่ไหน หักแรงจะดริฟต์ (rotationRate.y คือการหมุนรอบแกนเดียวกับ roll)
struct SteeringView: View {
    @State private var carX = 0.0        // ตำแหน่งรถ -1 (ซ้ายสุด) ถึง 1 (ขวาสุด)
    @State private var roll = 0.0
    @State private var isDrifting = false
    @State private var driftUntil = Date.distantPast

    var body: some View {
        VStack(spacing: 24) {
            GeometryReader { geo in
                let half = geo.size.width / 2 - 40
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(.gray.opacity(0.35))
                    Rectangle()   // เส้นกลางถนน
                        .fill(.white.opacity(0.6))
                        .frame(width: 4)
                    Image(systemName: "car.rear.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.red)
                        .rotationEffect(.degrees(isDrifting ? roll * 180 / .pi : 0))
                        .offset(x: carX * half)
                }
            }
            .frame(height: 220)
            Text(isDrifting ? "ดริฟต์!" : " ")
                .font(.system(size: 48, weight: .heavy))
                .foregroundStyle(.orange)
            Text(String(format: "เลี้ยว %+.0f°", roll * 180 / .pi))
                .font(.title2)
                .monospacedDigit()
        }
        .padding(32)
        .navigationTitle("พวงมาลัยเกมแข่งรถ")
        .onAppear {
            startMotionUpdates { data in
                roll = data.attitude.roll
                // เอียง 30° ถือว่าเลี้ยวเต็มที่ ยิ่งเอียงมาก รถยิ่งเลื่อนเร็ว
                let steer = min(max(roll / (.pi / 6), -1), 1)
                carX = min(max(carX + steer * 0.03, -1), 1)

                // หักพวงมาลัยเร็วกว่า 3 rad/s ให้ดริฟต์ค้างไว้ครึ่งวินาที
                if abs(data.rotationRate.y) > 3 { driftUntil = .now.addingTimeInterval(0.5) }
                isDrifting = Date.now < driftUntil
            }
        }
        .onDisappear { stopMotionUpdates() }
    }
}

import SwiftUI

/// สีและไอคอนของเครื่องดื่มแต่ละชนิด ใช้ร่วมกันทั้งใน app และ widget
extension Beverage {
    var color: Color {
        switch self {
        case .water: .blue
        case .tea: .green
        case .coffee: .brown
        case .milk: .indigo
        case .juice: .orange
        }
    }
}

/// ไอคอนกลมสีอ่อน มีสัญลักษณ์ของเครื่องดื่มอยู่ตรงกลาง
struct BeverageIcon: View {
    let beverage: Beverage
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: beverage.symbol)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(beverage.color.gradient)
            .frame(width: size, height: size)
            .background(beverage.color.opacity(0.15), in: .circle)
    }
}

/// วงแหวนความคืบหน้าของวันนี้ แบบเดียวกับวงแหวนใน Fitness
struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 18

    var body: some View {
        ZStack {
            Circle()
                .stroke(.blue.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1))
                .stroke(
                    LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .animation(.spring(duration: 0.6), value: progress)
    }
}

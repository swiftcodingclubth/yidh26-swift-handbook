import SwiftUI

/// แท็บละหัวข้อ เรียงตามลำดับในหน้า Workshop 3 ของ handbook
/// โค้ดจาก handbook อยู่ใน SensorParts/ (sensor) และ MLParts/ (machine learning) ส่วน Tabs/ เป็นหน้าจอตัวอย่าง
struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Motion", systemImage: "gyroscope") { MotionTab() }
            Tab("Sound", systemImage: "waveform") { SoundTab() }
            Tab("LiDAR", systemImage: "scope") { LidarTab() }
            Tab("Core ML", systemImage: "brain") { CoreMLTab() }
        }
    }
}

/// แถวในรายการของแต่ละแท็บ
struct UseCaseRow: View {
    let title: String
    let detail: String
    let icon: String

    var body: some View {
        Label {
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: icon)
        }
    }
}

#Preview {
    ContentView()
}

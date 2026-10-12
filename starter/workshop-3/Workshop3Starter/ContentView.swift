import SwiftUI

/// หน้าแรก: เลือก use case ทุกหน้าใช้แค่โค้ดใน Motion.swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("เริ่มจากตัวอย่างใน handbook") {
                    NavigationLink {
                        MotionView()
                    } label: {
                        UseCaseRow(title: "MotionView", detail: "แรงเหวี่ยงแกน x, y, z · userAcceleration", icon: "arrow.left.and.right")
                    }
                    NavigationLink {
                        AttitudeView()
                    } label: {
                        UseCaseRow(title: "AttitudeView", detail: "มุม pitch, roll, yaw · attitude", icon: "rotate.3d")
                    }
                }
                Section("Use case") {
                    NavigationLink {
                        LevelView()
                    } label: {
                        UseCaseRow(title: "เอียงหรือไม่เอียง?", detail: "เช็กว่าโต๊ะเอียงไหม · attitude.roll", icon: "level")
                    }
                    NavigationLink {
                        ShakeMenuView()
                    } label: {
                        UseCaseRow(title: "เขย่าสุ่มเมนูมื้อเที่ยง", detail: "วันนี้กินอะไรดี · detectGesture", icon: "fork.knife")
                    }
                    NavigationLink {
                        StairsView()
                    } label: {
                        UseCaseRow(title: "นับชั้นที่เดินขึ้นบันได", detail: "app ออกกำลังกาย · CMAltimeter", icon: "figure.stairs")
                    }
                }
                Section {
                    Text("Simulator ไม่มี sensor การเคลื่อนไหว ต้อง run บน iPad จริง")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Core Motion")
        }
    }
}

private struct UseCaseRow: View {
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

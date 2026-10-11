import AVFoundation
import SwiftUI

/// ขั้น 3: Vision — หาตำแหน่งนิ้วจากกล้องสด แล้วแปลงเป็นค้อน กรรไกร กระดาษ
struct HandTab: View {
    @State private var model = HandModel()
    @State private var position: AVCaptureDevice.Position = .front

    var body: some View {
        ZStack(alignment: .top) {
            CameraView(position: position, onFrame: model.handle) {
                HandPointsOverlay(points: model.points)
            }
            // เปลี่ยนกล้องแล้วสร้าง CameraView ใหม่
            .id(position)

            HStack {
                Text(model.sign.rawValue)
                    .font(.system(size: 100))
                Spacer()
                Button("สลับกล้อง", systemImage: "arrow.triangle.2.circlepath.camera") {
                    position = (position == .front) ? .back : .front
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

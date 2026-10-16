// Copy มาจาก Workshop 5 (starter/workshop-5/Workshop5Starter/VisionParts/CameraView.swift) ไม่ได้แก้
import AVFoundation
import SwiftUI

/// กล้องสดสำหรับ Vision: แสดงภาพจากกล้อง และส่งแต่ละ frame ให้ `onFrame` บน main thread
///
/// - Frame ถูกหมุนให้ตั้งตรงตามทิศของเครื่องแล้ว และกล้องหน้าถูกกลับด้านแบบกระจกให้ตรงกับภาพบนจอ
///   จึงส่งให้ Vision ได้เลยโดยไม่ต้องบอก orientation
/// - `overlay` ถูกวาดทับในกรอบเดียวกับภาพจากกล้องพอดี ตำแหน่ง 0–1 จาก Vision จึงตรงกับภาพ
/// - ขอสิทธิ์กล้องเอง และหยุดกล้องเมื่อ view หายจากจอ เช่น สลับไปแท็บอื่น
///
/// ต้องมี `NSCameraUsageDescription` ใน Info.plist
struct CameraView<Overlay: View>: View {
    var position: AVCaptureDevice.Position = .back
    var onFrame: (CVPixelBuffer) -> Void
    @ViewBuilder var overlay: () -> Overlay

    @State private var isAuthorized: Bool?
    @State private var isVisible = false

    var body: some View {
        GeometryReader { geo in
            Group {
                switch isAuthorized {
                case true?:
                    ZStack {
                        CameraPreview(position: position, isActive: isVisible, onFrame: onFrame)
                        overlay()
                    }
                    // Frame ขนาด 640 × 480 (4:3) จัดกรอบให้สัดส่วนเท่าภาพ ภาพจะไม่ถูกตัดและ overlay ตรงกับภาพ
                    .aspectRatio(geo.size.width > geo.size.height ? 4.0 / 3.0 : 3.0 / 4.0,
                                 contentMode: .fit)
                case false?:
                    ContentUnavailableView("ไม่ได้รับสิทธิ์กล้อง", systemImage: "camera.slash",
                        description: Text("เปิดได้ที่ Settings → ชื่อ app → Camera"))
                case nil:
                    ProgressView()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(.black)
        .task {
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        }
        // TabView ไม่ทำลายแท็บที่ซ่อนอยู่ จึงต้องหยุดกล้องเอง ไม่อย่างนั้นจะแย่งกล้องกับแท็บอื่น
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }
}

extension CameraView where Overlay == EmptyView {
    init(position: AVCaptureDevice.Position = .back,
         onFrame: @escaping (CVPixelBuffer) -> Void) {
        self.init(position: position, onFrame: onFrame) { EmptyView() }
    }
}

// MARK: - ส่วนข้างล่างนี้ไม่ต้องแก้

private struct CameraPreview: UIViewRepresentable {
    let position: AVCaptureDevice.Position
    let isActive: Bool
    let onFrame: (CVPixelBuffer) -> Void

    func makeCoordinator() -> CameraController { CameraController() }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.videoGravity = .resizeAspectFill
        context.coordinator.onFrame = onFrame
        context.coordinator.configure(position: position, previewLayer: view.previewLayer)
        context.coordinator.setRunning(isActive)
        return view
    }

    func updateUIView(_ view: PreviewView, context: Context) {
        context.coordinator.onFrame = onFrame
        context.coordinator.setRunning(isActive)
    }

    static func dismantleUIView(_ view: PreviewView, coordinator: CameraController) {
        coordinator.stop()
    }
}

private final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

@MainActor
private final class CameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onFrame: (CVPixelBuffer) -> Void = { _ in }

    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "CameraView.session")
    private weak var previewLayer: AVCaptureVideoPreviewLayer?
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservations: [NSKeyValueObservation] = []
    private var isRunning = false

    func configure(position: AVCaptureDevice.Position, previewLayer: AVCaptureVideoPreviewLayer) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        session.beginConfiguration()
        session.sessionPreset = .vga640x480   // ภาพเล็กพอสำหรับ Vision และประหยัดแบตเตอรี่
        if session.canAddInput(input) { session.addInput(input) }
        output.alwaysDiscardsLateVideoFrames = true   // ทำไม่ทันก็ทิ้ง frame เก่า ไม่ต่อคิว
        output.setSampleBufferDelegate(self, queue: .main)
        if session.canAddOutput(output) { session.addOutput(output) }
        if position == .front, let connection = output.connection(with: .video),
           connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true   // ให้ frame เป็นภาพกระจกเหมือน preview
        }
        session.commitConfiguration()
        previewLayer.session = session
        self.previewLayer = previewLayer

        // หมุน preview และ frame ตามทิศของเครื่อง
        let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: previewLayer)
        rotationCoordinator = coordinator
        rotationObservations = [
            coordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.initial, .new]) {
                [weak self] coordinator, _ in
                let controller = self
                let angle = coordinator.videoRotationAngleForHorizonLevelPreview
                Task { @MainActor in controller?.previewLayer?.connection?.videoRotationAngle = angle }
            },
            coordinator.observe(\.videoRotationAngleForHorizonLevelCapture, options: [.initial, .new]) {
                [weak self] coordinator, _ in
                let controller = self
                let angle = coordinator.videoRotationAngleForHorizonLevelCapture
                Task { @MainActor in controller?.setCaptureRotation(angle) }
            },
        ]
    }

    func setRunning(_ running: Bool) {
        guard running != isRunning else { return }
        isRunning = running
        nonisolated(unsafe) let session = session
        sessionQueue.async { running ? session.startRunning() : session.stopRunning() }
    }

    func stop() {
        rotationObservations = []
        setRunning(false)
    }

    private func setCaptureRotation(_ angle: CGFloat) {
        guard let connection = output.connection(with: .video),
              connection.isVideoRotationAngleSupported(angle) else { return }
        connection.videoRotationAngle = angle
    }

    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        // Delegate queue คือ .main จึงอยู่บน main thread แน่นอน และ buffer ไม่ถูกใช้ที่อื่นต่อ
        nonisolated(unsafe) let pixelBuffer = sampleBuffer.imageBuffer
        MainActor.assumeIsolated {
            if let pixelBuffer { onFrame(pixelBuffer) }
        }
    }
}

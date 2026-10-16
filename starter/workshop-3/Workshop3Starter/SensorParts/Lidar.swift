// โค้ดทั้งหมดในไฟล์นี้มาจากหน้า LiDAR ใน handbook
import ARKit

// MARK: - เช็กว่าเครื่องมี LiDAR

var hasLiDAR: Bool {
    ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth)
}

// MARK: - วัดระยะที่จุดกลางจอ

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

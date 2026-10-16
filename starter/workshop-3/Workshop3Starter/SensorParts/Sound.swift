// โค้ดทั้งหมดในไฟล์นี้มาจากหน้า Sound recognition ใน handbook
import AVFoundation
import SoundAnalysis

// MARK: - ฟังและจดจำเสียง

final class SoundListener: NSObject, SNResultsObserving {
    private let engine = AVAudioEngine()
    private var analyzer: SNAudioStreamAnalyzer?
    private let queue = DispatchQueue(label: "SoundAnalysis")
    var onResult: (String, Double) -> Void = { _, _ in }

    func start() throws {
        // 1. ตั้งค่า audio session ให้รับเสียงจากไมโครโฟน
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement)
        try session.setActive(true)

        // 2. สร้าง analyzer และ request ของ classifier ในตัว
        let format = engine.inputNode.outputFormat(forBus: 0)
        let analyzer = SNAudioStreamAnalyzer(format: format)
        let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
        try analyzer.add(request, withObserver: self)
        self.analyzer = analyzer

        // 3. ส่งเสียงจากไมโครโฟนให้ analyzer ทีละชิ้น
        engine.inputNode.installTap(onBus: 0, bufferSize: 8192, format: format) { [weak self] buffer, time in
            self?.queue.async {
                self?.analyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
        try engine.start()
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        analyzer?.removeAllRequests()
    }

    // 4. ได้ผลลัพธ์ทุกช่วงเวลา
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let top = result.classifications.first else { return }
        DispatchQueue.main.async {
            self.onResult(top.identifier, top.confidence)
        }
    }
}

import CoreMotion
import Foundation
import Observation

/// เก็บค่า Core Motion ระหว่างอัด แล้วเขียนเป็น CSV ใน MotionData/<ท่า>/<ท่า>-01.csv
/// Column ตรงกับ input ในหน้า Core ML: accelX, accelY, accelZ, rotationX, rotationY, rotationZ
@Observable
final class Recorder {
    private(set) var isRecording = false
    private(set) var rows: [String] = []
    private(set) var allFiles: [URL] = []
    /// MotionData.zip สำหรับส่งด้วย AirDrop แตก zip บน Mac แล้วได้ folder ตามชื่อท่าเลย
    private(set) var exportURL: URL?

    let folder = URL.documentsDirectory.appending(path: "MotionData")
    private var startTime: TimeInterval?

    init() { reload() }

    /// ชื่อท่าที่มีไฟล์อยู่ เรียงตามตัวอักษร
    var labels: [String] {
        Set(allFiles.map { $0.deletingLastPathComponent().lastPathComponent }).sorted()
    }

    func files(in label: String) -> [URL] {
        allFiles.filter { $0.deletingLastPathComponent().lastPathComponent == label }
    }

    // MARK: - อัด

    func start() {
        rows = []
        startTime = nil
        isRecording = true
    }

    func add(_ data: CMDeviceMotion) {
        guard isRecording else { return }
        let start = startTime ?? data.timestamp
        startTime = start
        let a = data.userAcceleration
        let r = data.rotationRate
        rows.append([data.timestamp - start, a.x, a.y, a.z, r.x, r.y, r.z]
            .map { String(format: "%.5f", $0) }
            .joined(separator: ","))
    }

    func cancel() {
        isRecording = false
        rows = []
    }

    /// บันทึกเป็นไฟล์ใหม่ เช่น shake-01.csv, shake-02.csv
    func save(label: String) throws {
        isRecording = false
        guard !rows.isEmpty else { return }

        let labelFolder = folder.appending(path: label)
        try FileManager.default.createDirectory(at: labelFolder, withIntermediateDirectories: true)
        var number = 1
        var file: URL
        repeat {
            file = labelFolder.appending(path: String(format: "%@-%02d.csv", label, number))
            number += 1
        } while FileManager.default.fileExists(atPath: file.path(percentEncoded: false))

        let header = "timestamp,accelX,accelY,accelZ,rotationX,rotationY,rotationZ"
        try ([header] + rows).joined(separator: "\n").write(to: file, atomically: true, encoding: .utf8)
        rows = []
        reload()
    }

    // MARK: - จัดการไฟล์

    func delete(_ file: URL) {
        try? FileManager.default.removeItem(at: file)
        // ลบ folder ท่าที่ว่างแล้ว จะได้ไม่ติดไปใน zip
        let labelFolder = file.deletingLastPathComponent()
        if (try? FileManager.default.contentsOfDirectory(atPath: labelFolder.path(percentEncoded: false)))?.isEmpty == true {
            try? FileManager.default.removeItem(at: labelFolder)
        }
        reload()
    }

    func deleteAll() {
        try? FileManager.default.removeItem(at: folder)
        reload()
    }

    func reload() {
        let found = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: nil)?
            .compactMap { $0 as? URL } ?? []
        allFiles = found.filter { $0.pathExtension == "csv" }
            .sorted { $0.path() < $1.path() }
        exportURL = allFiles.isEmpty ? nil : makeZip()
    }

    /// บีบ folder MotionData ทั้ง folder เป็น MotionData.zip โดยยังเก็บ folder ย่อยตามชื่อท่าไว้
    private func makeZip() -> URL? {
        let output = FileManager.default.temporaryDirectory.appending(path: "MotionData.zip")
        var result: URL?
        var error: NSError?
        // option .forUploading ให้ระบบสร้าง zip ของ folder ให้
        NSFileCoordinator().coordinate(readingItemAt: folder, options: .forUploading, error: &error) { zip in
            try? FileManager.default.removeItem(at: output)
            if (try? FileManager.default.copyItem(at: zip, to: output)) != nil {
                result = output
            }
        }
        return result
    }
}

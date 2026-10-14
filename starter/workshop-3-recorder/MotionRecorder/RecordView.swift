import CoreMotion
import SwiftUI

/// อัดท่าทางเป็นไฟล์ CSV สำหรับ train Activity Classifier ใน Create ML
/// เลือกท่า กดอัด ทำท่าซ้ำๆ แล้วกดหยุด จากนั้นกด "ส่ง MotionData.zip" แล้ว AirDrop มาที่ Mac
struct RecordView: View {
    @State private var recorder = Recorder()
    @State private var label = "shake"
    @State private var countdown: Int?
    @State private var errorMessage: String?
    @State private var confirmDeleteAll = false

    // ชื่อท่าตัวอย่างจากหน้า Create ML ชื่อนี้จะเป็นชื่อที่ model ตอบกลับมา
    private let presets = ["shake", "tilt", "circle", "idle"]

    var body: some View {
        Form {
            Section("ท่าที่จะอัด") {
                Picker("ท่า", selection: $label) {
                    ForEach(presets, id: \.self) { Text($0) }
                    if !presets.contains(label) { Text(label).tag(label) }
                }
                .pickerStyle(.segmented)
                TextField("หรือพิมพ์ชื่อท่าเอง (ภาษาอังกฤษ ไม่เว้นวรรค)", text: $label)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .disabled(recorder.isRecording || countdown != nil)

            Section {
                recordButton
                if recorder.isRecording {
                    LabeledContent("อัดไปแล้ว", value: String(format: "%.1f วินาที (%d ค่า)", Double(recorder.rows.count) / 50, recorder.rows.count))
                }
                if !motion.isDeviceMotionAvailable {
                    Text("Simulator ไม่มี sensor การเคลื่อนไหว ต้องอัดบน iPad จริง").foregroundStyle(.orange)
                }
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
            } footer: {
                Text("ทำท่าละ 5–10 รอบ รอบละไม่กี่วินาที จับเครื่องแบบเดียวกันทุกครั้ง และอัดท่า idle (ถือนิ่งๆ) ด้วย")
            }

            if let exportURL = recorder.exportURL {
                Section {
                    ShareLink(item: exportURL) {
                        Label("ส่ง MotionData.zip (\(recorder.allFiles.count) ไฟล์)", systemImage: "square.and.arrow.up")
                    }
                } footer: {
                    Text("AirDrop มาที่ Mac แล้วดับเบิลคลิก zip จะได้ folder MotionData ที่แยกตามชื่อท่า ลากไปวางใน Create ML ได้เลย")
                }
            }

            ForEach(recorder.labels, id: \.self) { folder in
                Section("\(folder)/ · \(recorder.files(in: folder).count) ไฟล์") {
                    ForEach(recorder.files(in: folder), id: \.self) { file in
                        Label(file.lastPathComponent, systemImage: "doc.text")
                    }
                    .onDelete { offsets in
                        offsets.map { recorder.files(in: folder)[$0] }.forEach(recorder.delete)
                    }
                }
            }
        }
        .navigationTitle("Motion Recorder")
        .toolbar {
            if !recorder.allFiles.isEmpty {
                Button("ลบทั้งหมด", systemImage: "trash", role: .destructive) { confirmDeleteAll = true }
            }
        }
        .confirmationDialog("ลบไฟล์ที่อัดไว้ทั้งหมด?", isPresented: $confirmDeleteAll, titleVisibility: .visible) {
            Button("ลบ \(recorder.allFiles.count) ไฟล์", role: .destructive) { recorder.deleteAll() }
        }
        .onAppear {
            recorder.reload()
            startMotionUpdates { data in recorder.add(data) }   // 50 Hz เท่ากับตอนใช้งานจริง
        }
        .onDisappear {
            stopMotionUpdates()
            recorder.cancel()
        }
    }

    private var recordButton: some View {
        Button(action: toggle) {
            Group {
                if let countdown {
                    Text("เริ่มใน \(countdown)…")
                } else if recorder.isRecording {
                    Label("หยุดและบันทึก", systemImage: "stop.fill")
                } else {
                    Label("อัดท่า \(cleanLabel)", systemImage: "record.circle")
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .tint(recorder.isRecording ? .red : .accentColor)
        .disabled(countdown != nil || cleanLabel.isEmpty || !motion.isDeviceMotionAvailable)
    }

    private var cleanLabel: String {
        label.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
    }

    private func toggle() {
        if recorder.isRecording {
            do {
                try recorder.save(label: cleanLabel)
            } catch {
                errorMessage = error.localizedDescription
            }
        } else {
            // นับถอยหลัง 3 วินาที ให้มีเวลาจับเครื่องให้พร้อม
            Task {
                errorMessage = nil
                for n in [3, 2, 1] {
                    countdown = n
                    try? await Task.sleep(for: .seconds(1))
                }
                countdown = nil
                recorder.start()
            }
        }
    }
}

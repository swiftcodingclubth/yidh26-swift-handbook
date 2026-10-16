import AVFoundation
import PhotosUI
import SwiftUI

/// หน้าทายรูปด้วย image classifier ตัวไหนก็ได้ ใช้ได้ทั้งรูปจาก Photos และกล้องสด
/// ใช้ AnyImageClassifier จาก handbook หน้า "ใช้ model ของคนอื่น" ใช้หน้านี้กับ CommunityClassifier
struct AnyModelView: View {
    let modelName: String
    let title: String

    @State private var classifier: AnyImageClassifier?
    @State private var useCamera = false
    @State private var item: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var guesses: [ImageGuess] = []
    @State private var isBusy = false

    var body: some View {
        Group {
            if classifier == nil {
                ContentUnavailableView {
                    Label("ยังไม่มี \(modelName)", systemImage: "shippingbox")
                } description: {
                    Text("ลากไฟล์ \(modelName).mlmodel หรือ \(modelName).mlpackage เข้า project แล้วติ๊ก target Workshop3Starter จากนั้น run ใหม่")
                }
            } else {
                VStack(spacing: 16) {
                    Picker("ที่มาของภาพ", selection: $useCamera) {
                        Text("รูปจาก Photos").tag(false)
                        Text("กล้องสด").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 400)

                    if useCamera {
                        CameraView(position: .back, onFrame: handle)
                            .clipShape(.rect(cornerRadius: 16))
                    } else {
                        if let image {
                            Image(uiImage: image).resizable().scaledToFit()
                                .frame(maxHeight: 360)
                                .clipShape(.rect(cornerRadius: 16))
                        }
                        PhotosPicker("เลือกรูป", selection: $item, matching: .images)
                            .buttonStyle(.borderedProminent)
                    }
                    GuessList(guesses: guesses)
                }
                .padding()
            }
        }
        .navigationTitle(title)
        .task { classifier = AnyImageClassifier(named: modelName) }
        .onChange(of: useCamera) { guesses = [] }
        .onChange(of: item) {
            Task {
                guard let data = try? await item?.loadTransferable(type: Data.self),
                      let picked = UIImage(data: data) else { return }
                image = picked
                guesses = (try? await classifier?.classify(picked)) ?? []
            }
        }
    }

    private func handle(_ frame: CVPixelBuffer) {
        guard !isBusy, let classifier else { return }   // frame ก่อนหน้ายังทายไม่เสร็จ ข้ามไปก่อน
        isBusy = true
        Task {
            defer { isBusy = false }
            guesses = (try? await classifier.classify(frame)) ?? []
        }
    }
}

/// 3 คำตอบแรกพร้อมแถบความมั่นใจ
struct GuessList: View {
    let guesses: [ImageGuess]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(guesses.prefix(3)) { guess in
                HStack {
                    Text(guess.label).font(.title3.bold()).lineLimit(1)
                    Spacer()
                    Text("\(Int(guess.confidence * 100))%").monospacedDigit()
                }
                ProgressView(value: guess.confidence)
            }
        }
        .frame(maxWidth: 500)
        .animation(.easeInOut, value: guesses.map(\.label))
    }
}

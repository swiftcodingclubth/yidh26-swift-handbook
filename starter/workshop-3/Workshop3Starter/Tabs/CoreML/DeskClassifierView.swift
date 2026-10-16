import AVFoundation
import SwiftUI

/// Workshop: ของบนโต๊ะคืออะไร
/// ใช้ MobileNetV2 ของ Apple (ไม่ต้อง train) กับกล้องสด หันกล้องไปที่ของบนโต๊ะ app บอกเป็นภาษาไทย
/// กล้องและการทายทำไว้ให้แล้ว เขียนเฉพาะส่วนที่มี TODO เฉลยอยู่ใน starter/workshop-3/Solutions/DeskClassifierView.swift
///
/// TODO 1: หันกล้องไปที่ของบนโต๊ะทีละชิ้น แล้วจดว่า model เรียกแต่ละชิ้นว่าอะไร (ดูจากรายการคำตอบด้านล่างจอ)
struct DeskClassifierView: View {
    @State private var classifier = AnyImageClassifier(named: "MobileNetV2")
    @State private var guesses: [ImageGuess] = []
    @State private var isBusy = false

    var body: some View {
        CameraView(position: .back, onFrame: handle)
            .ignoresSafeArea()
            .overlay(alignment: .bottom) { answer }
            .navigationTitle("ของบนโต๊ะคืออะไร")
    }

    private var answer: some View {
        let shown = describe(guesses)
        return VStack(spacing: 8) {
            Image(systemName: shown.icon).font(.system(size: 64))
            Text(shown.name).font(.largeTitle.bold())
            GuessList(guesses: guesses.map(\.shortened))   // คำตอบดิบจาก model ใช้ทำ TODO 1
        }
        .padding(24)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
        .padding(24)
        .animation(.easeInOut, value: shown.name)
    }

    /// TODO 2: ถ้าความมั่นใจของคำตอบแรกต่ำกว่าเกณฑ์ ให้แสดงว่า "ไม่แน่ใจ" แทนการเดา
    /// TODO 3: แปลงชื่อจาก model (เช่น "coffee mug") เป็น SF Symbol และชื่อภาษาไทย (เช่น cup.and.saucer.fill, แก้วกาแฟ)
    ///         ของที่ไม่ได้อยู่ในรายการ ให้แสดงว่าไม่ใช่ของบนโต๊ะที่รู้จัก
    private func describe(_ guesses: [ImageGuess]) -> (icon: String, name: String) {
        guard let top = guesses.first?.shortened else { return ("camera", "หันกล้องไปที่ของบนโต๊ะ") }
        return ("questionmark.circle", top.label)
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

private extension ImageGuess {
    /// MobileNetV2 ตั้งชื่อหลายแบบคั่นด้วยจุลภาค เช่น "coffee mug" หรือ "ballpoint, ballpoint pen, ballpen, Biro" เอาแค่ชื่อแรก
    var shortened: ImageGuess {
        ImageGuess(label: label.components(separatedBy: ",").first ?? label, confidence: confidence)
    }
}

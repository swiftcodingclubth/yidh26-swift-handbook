import AVFoundation
import SwiftUI

/// Demo: เป่ายิ้งฉุบกับ iPad (มีเฉพาะ branch final)
struct GameTab: View {
    private enum Phase: Equatable {
        case ready
        case countdown(Int)
        case result(player: HandSign, ipad: HandSign)
    }

    @State private var model = HandModel()
    @State private var phase: Phase = .ready

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraView(position: .front, onFrame: model.handle) {
                HandPointsOverlay(points: model.points)
            }

            VStack(spacing: 16) {
                switch phase {
                case .ready:
                    Text("พร้อมไหม?").font(.largeTitle.bold())
                case .countdown(let n):
                    Text("\(n)").font(.system(size: 120, weight: .black))
                case .result(let player, let ipad):
                    HStack(spacing: 40) {
                        VStack { Text(player.rawValue).font(.system(size: 80)); Text("คุณ") }
                        Text("vs").font(.title)
                        VStack { Text(ipad.rawValue).font(.system(size: 80)); Text("iPad") }
                    }
                    Text(verdict(player: player, ipad: ipad)).font(.largeTitle.bold())
                }
                Button(phase == .ready ? "เริ่ม" : "อีกรอบ") { Task { await play() } }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(isCountingDown)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 24))
            .padding()
        }
    }

    private var isCountingDown: Bool {
        if case .countdown = phase { true } else { false }
    }

    private func play() async {
        for n in [3, 2, 1] {
            phase = .countdown(n)
            try? await Task.sleep(for: .seconds(1))
        }
        let ipad = [HandSign.rock, .scissors, .paper].randomElement()!
        phase = .result(player: model.sign, ipad: ipad)
    }

    private func verdict(player: HandSign, ipad: HandSign) -> String {
        let beats: [HandSign: HandSign] = [.rock: .scissors, .scissors: .paper, .paper: .rock]
        if player == .unknown { return "ไม่เห็นมือ ลองใหม่" }
        if player == ipad { return "เสมอ" }
        return beats[player] == ipad ? "คุณชนะ! 🎉" : "iPad ชนะ"
    }
}

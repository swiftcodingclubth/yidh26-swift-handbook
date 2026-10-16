import SwiftUI

/// Use case: บันทึกความรู้สึก พิมพ์แล้ว emoji สี และ animation เปลี่ยนตามอารมณ์ทันที
/// ใช้ EmotionDetector (text classifier จาก Create ML) พิมพ์เป็นภาษาอังกฤษ
/// ถ้า model มั่นใจไม่ถึง 40% จะขึ้น 🤔 แทนการเดา ยิ่งมั่นใจ สียิ่งเข้มและวงแหวนยิ่งเต็ม
struct MoodView: View {
    @State private var detector = EmotionDetector()
    @State private var text = ""
    @State private var scores: [(label: String, confidence: Double)] = []
    @FocusState private var isTyping: Bool

    /// มั่นใจต่ำกว่านี้ ถือว่ายังไม่แน่ใจ ปรับได้ด้วยการลองพิมพ์จริง
    private let minimumConfidence = 0.4

    private let examples = [
        "today was a really good day",
        "i miss my grandmother so much",
        "i am furious that they cancelled my order",
        "i'm nervous about my exam tomorrow",
        "i adore my little puppy",
        "i can't believe i won the lottery",
    ]

    var body: some View {
        GeometryReader { geo in
            // ที่ว่างลดลงเมื่อ keyboard ขึ้น จึงย่อ emoji และซ่อนการ์ดอันดับ
            let roomy = geo.size.height > 560
            VStack(spacing: 28) {
                Spacer(minLength: 0)
                face(size: min(150, geo.size.height * 0.22))
                if roomy && !scores.isEmpty {
                    topEmotions.transition(.move(edge: .bottom).combined(with: .opacity))
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .animation(.spring(duration: 0.4), value: roomy)
        }
        .padding(.horizontal, 24)
        .background { MoodBackground(mood: mood, strength: strength).onTapGesture { isTyping = false } }
        // ช่องพิมพ์อยู่ใน safe area ด้านล่าง ระบบจึงดันขึ้นตาม keyboard ให้เอง
        .safeAreaInset(edge: .bottom) { input }
        .onChange(of: text) {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                scores = trimmed.isEmpty ? [] : detector.scores(for: trimmed)   // เร็วมาก ทายทุกครั้งที่พิมพ์ได้เลย
            }
        }
    }

    // MARK: - อารมณ์ที่แสดง

    /// อารมณ์ที่มั่นใจที่สุด ถ้ามั่นใจไม่พอให้เป็น "ยังไม่แน่ใจ"
    private var mood: Mood {
        guard let top = scores.first else { return .waiting }
        return top.confidence >= minimumConfidence ? Mood(label: top.label) : .unsure
    }

    /// ความเข้มของสี 0–1 ตามความมั่นใจ
    private var strength: Double {
        guard let top = scores.first, top.confidence >= minimumConfidence else { return 0 }
        return top.confidence
    }

    private var confidence: Double { scores.first?.confidence ?? 0 }

    // MARK: - emoji กลางจอ

    private func face(size: CGFloat) -> some View {
        VStack(spacing: 16) {
            ZStack {
                // วงแหวนความมั่นใจ
                Circle()
                    .stroke(.white.opacity(0.35), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: confidence)
                    .stroke(AngularGradient(colors: mood.colors + [mood.colors[0]], center: .center),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .shadow(color: mood.colors[0].opacity(0.6), radius: 10)

                // emoji ลอยขึ้นลงตลอด และเด้งเข้ามาใหม่เมื่อเปลี่ยนอารมณ์
                Text(mood.emoji)
                    .font(.system(size: size))
                    .phaseAnimator([false, true]) { emoji, up in
                        emoji
                            .offset(y: up ? -8 : 8)
                            .rotationEffect(.degrees(up ? 4 : -4))
                    } animation: { _ in .easeInOut(duration: 1.6) }
                    .id(mood)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.3).combined(with: .opacity),
                        removal: .scale(scale: 1.5).combined(with: .opacity)))
            }
            .frame(width: size * 1.7, height: size * 1.7)

            Text(mood.name)
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .contentTransition(.opacity)

            if !scores.isEmpty {
                Text("มั่นใจ \(Int(confidence * 100))%")
                    .font(.headline.monospacedDigit())
                    .contentTransition(.numericText(value: confidence))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .glassEffect(.regular, in: .capsule)
            }
        }
        .animation(.spring(duration: 0.6, bounce: 0.45), value: mood)
        .animation(.spring(duration: 0.6), value: confidence)
    }

    // MARK: - 3 อารมณ์ที่มั่นใจที่สุด

    /// ให้เห็นว่า model ลังเลระหว่างอารมณ์อะไร
    private var topEmotions: some View {
        VStack(spacing: 14) {
            ForEach(scores.prefix(3), id: \.label) { score in
                let item = Mood(label: score.label)
                HStack(spacing: 12) {
                    Text(item.emoji).font(.title2)
                    Text(item.name)
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    GeometryReader { bar in
                        Capsule().fill(.white.opacity(0.35))
                        Capsule()
                            .fill(LinearGradient(colors: item.colors, startPoint: .leading, endPoint: .trailing))
                            .frame(width: bar.size.width * score.confidence)
                    }
                    .frame(height: 12)
                    Text("\(Int(score.confidence * 100))%")
                        .font(.subheadline.monospacedDigit())
                        .contentTransition(.numericText(value: score.confidence))
                        .frame(width: 48, alignment: .trailing)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: 520)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }

    // MARK: - ช่องพิมพ์

    private var input: some View {
        VStack(spacing: 12) {
            // ตัวอย่างประโยค แตะเพื่อลอง
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(examples, id: \.self) { example in
                        Button(example) { text = example }
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glassEffect(.regular.interactive(), in: .capsule)
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 24)
            }

            HStack(alignment: .bottom, spacing: 12) {
                TextField("วันนี้รู้สึกอย่างไร พิมพ์เป็นภาษาอังกฤษ", text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .font(.title3)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)   // แป้นพิมพ์ภาษาอังกฤษ เพราะ model เข้าใจแค่ภาษาอังกฤษ
                    .focused($isTyping)

                if !text.isEmpty {
                    Button("ล้าง", systemImage: "xmark.circle.fill") { text = "" }
                        .labelStyle(.iconOnly)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .transition(.scale.combined(with: .opacity))
                }
                if isTyping {
                    Button("ซ่อนแป้นพิมพ์", systemImage: "keyboard.chevron.compact.down") { isTyping = false }
                        .labelStyle(.iconOnly)
                        .font(.title2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .glassEffect(.regular, in: .rect(cornerRadius: 28))
            .frame(maxWidth: 700)
            .padding(.horizontal, 24)
            .animation(.spring(duration: 0.3), value: text.isEmpty)
            .animation(.spring(duration: 0.3), value: isTyping)
        }
        .padding(.bottom, 12)
    }
}

// MARK: - พื้นหลัง

/// พื้นหลังสีตามอารมณ์ มีก้อนสีเบลอลอยช้า ๆ และ emoji เล็ก ๆ ลอยขึ้น
private struct MoodBackground: View {
    let mood: Mood
    let strength: Double

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    Color(.systemBackground)
                    LinearGradient(colors: mood.colors.map { $0.opacity(0.2 + 0.5 * strength) },
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    // ก้อนสีเบลอ 3 ก้อน เคลื่อนที่ช้า ๆ
                    blob(mood.colors[0], size: w * 0.9)
                        .offset(x: cos(t * 0.21) * w * 0.25, y: sin(t * 0.17) * h * 0.15 - h * 0.2)
                    blob(mood.colors[1], size: w * 0.8)
                        .offset(x: sin(t * 0.19) * w * 0.3, y: cos(t * 0.23) * h * 0.15 + h * 0.2)
                    blob(.white, size: w * 0.5)
                        .offset(x: cos(t * 0.13) * w * 0.3, y: sin(t * 0.29) * h * 0.1)
                        .opacity(0.5)
                    floatingEmoji(t: t, size: geo.size)
                }
                .animation(.easeInOut(duration: 0.8), value: mood)
                .animation(.easeInOut(duration: 0.8), value: strength)
            }
        }
        .ignoresSafeArea()
    }

    private func blob(_ color: Color, size: CGFloat) -> some View {
        Circle()
            .fill(color.opacity(0.15 + 0.55 * strength))
            .frame(width: size, height: size)
            .blur(radius: 90)
    }

    /// emoji ของอารมณ์ตอนนี้ ลอยจากล่างขึ้นบน ยิ่งมั่นใจยิ่งเห็นชัด
    private func floatingEmoji(t: Double, size: CGSize) -> some View {
        Canvas { context, canvas in
            guard strength > 0 else { return }
            let emoji = context.resolve(Text(mood.emoji).font(.system(size: 34)))
            for i in 0..<12 {
                let speed = 0.035 + Double(i % 4) * 0.012                    // สัดส่วนความสูงต่อวินาที
                let progress = (t * speed + Double(i) * 0.137).truncatingRemainder(dividingBy: 1)
                let x = (Double(i) * 0.379 + 0.05).truncatingRemainder(dividingBy: 1) + sin(t * 0.8 + Double(i)) * 0.03
                let y = 1.1 - progress * 1.2
                // จางลงตอนใกล้ขอบบนและล่าง
                context.opacity = sin(progress * .pi) * (0.15 + 0.45 * strength)
                context.draw(emoji, at: CGPoint(x: x * canvas.width, y: y * canvas.height))
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - ข้อมูลของแต่ละอารมณ์

/// emoji, ชื่อภาษาไทย และสีของแต่ละอารมณ์
private struct Mood: Hashable {
    let emoji: String
    let name: String
    let colors: [Color]

    static let waiting = Mood(emoji: "✍️", name: "เล่าให้ฟังหน่อย", colors: [.gray, .teal])
    static let unsure = Mood(emoji: "🤔", name: "ยังไม่แน่ใจ", colors: [.gray, .secondary])

    /// ชื่ออารมณ์จาก model → สิ่งที่แสดง ถ้า train อารมณ์อื่นเอง ให้เพิ่มที่นี่
    init(label: String) {
        switch label {
        case "joy": self.init(emoji: "😄", name: "มีความสุข", colors: [.yellow, .orange])
        case "love": self.init(emoji: "🥰", name: "รัก", colors: [.pink, .red])
        case "sadness": self.init(emoji: "😢", name: "เศร้า", colors: [.blue, .indigo])
        case "anger": self.init(emoji: "😠", name: "โกรธ", colors: [.red, .orange])
        case "fear": self.init(emoji: "😨", name: "กังวล", colors: [.purple, .indigo])
        case "surprise": self.init(emoji: "😲", name: "ประหลาดใจ", colors: [.cyan, .mint])
        default: self.init(emoji: "😐", name: label, colors: [.gray, .gray])
        }
    }

    private init(emoji: String, name: String, colors: [Color]) {
        self.emoji = emoji
        self.name = name
        self.colors = colors
    }
}

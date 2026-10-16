import AppIntents
import SwiftUI
import WidgetKit

struct WaterEntry: TimelineEntry {
    let date: Date
    let total: Int
}

struct WaterProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterEntry {
        WaterEntry(date: .now, total: 750)
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> Void) {
        completion(WaterEntry(date: .now, total: WaterData.todayTotal()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> Void) {
        // อ่านยอดล่าสุดจาก App Group แล้ว refresh อีกครั้งตอนเที่ยงคืนเพื่อเริ่มนับวันใหม่
        let entry = WaterEntry(date: .now, total: WaterData.todayTotal())
        let midnight = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
}

struct WaterWidgetView: View {
    let entry: WaterEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    ProgressRing(progress: Double(entry.total) / Double(WaterData.dailyGoal), lineWidth: 7)
                    Image(systemName: "drop.fill").font(.caption).foregroundStyle(.blue)
                }
                .frame(width: 40, height: 40)
                Spacer()
                Text("Today").font(.caption.bold()).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Text("\(entry.total.formatted()) ml")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .contentTransition(.numericText())
            // TODO Code-along 2 (ไม่บังคับ): เพิ่มปุ่ม Button(intent: LogWaterIntent(milliliters: 250))
        }
        .containerBackground(for: .widget) {
            LinearGradient(colors: [.cyan.opacity(0.25), .blue.opacity(0.15)], startPoint: .top, endPoint: .bottom)
        }
    }
}

struct WaterWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WaterWidget", provider: WaterProvider()) { entry in
            WaterWidgetView(entry: entry)
        }
        .configurationDisplayName("Water Today")
        .description("See today's total and log a glass.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    WaterWidget()
} timeline: {
    WaterEntry(date: .now, total: 750)
}

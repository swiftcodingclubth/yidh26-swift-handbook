import AppIntents
import SwiftUI
import WidgetKit

// --8<-- [start:control]
/// ปุ่มใน Control Center (และ Lock Screen) ที่ run LogWaterIntent ตัวเดิม
struct LogWaterControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "LogWaterControl") {
            ControlWidgetButton(action: LogWaterIntent(milliliters: 250)) {
                Label("Log 250 ml", systemImage: "drop.fill")
            }
        }
        .displayName("Log Water")
        .description("Log a glass of water.")
    }
}
// --8<-- [end:control]

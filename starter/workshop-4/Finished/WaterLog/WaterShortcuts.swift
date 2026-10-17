import AppIntents

// --8<-- [start:shortcuts]
/// App Shortcuts ใช้ได้ทันทีหลังติดตั้ง ไม่ต้องให้ผู้ใช้สร้าง shortcut เอง
/// ทุก phrase ต้องมี \(.applicationName)
struct WaterShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogWaterIntent(),
            phrases: [
                "Log water in \(.applicationName)",
                "Log a \(\.$beverage) in \(.applicationName)",
            ],
            shortTitle: "Log Water",
            systemImageName: "drop.fill"
        )
        AppShortcut(
            intent: GetTodayDrinksIntent(),
            phrases: ["How much did I drink in \(.applicationName)"],
            shortTitle: "Today's Drinks",
            systemImageName: "chart.bar.fill"
        )
    }

    static let shortcutTileColor: ShortcutTileColor = .blue
}
// --8<-- [end:shortcuts]

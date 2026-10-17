import AppIntents

// --8<-- [start:intent]
/// คืนรายการที่ดื่มวันนี้เป็น entity เพื่อส่งต่อให้ action อื่น เช่น "Use Model" ใน Shortcuts
struct GetTodayDrinksIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Today's Drinks"
    static let description = IntentDescription("Everything you drank today, newest first.")

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[DrinkEntity]> & ProvidesDialog {
        let store = WaterStore.shared
        store.reload()
        return .result(
            value: store.todayDrinks.map(DrinkEntity.init),
            dialog: "Today you drank \(store.todayTotal) of \(WaterData.dailyGoal) ml."
        )
    }
}
// --8<-- [end:intent]

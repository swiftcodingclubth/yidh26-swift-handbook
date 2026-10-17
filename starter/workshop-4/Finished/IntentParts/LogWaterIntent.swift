import AppIntents

// --8<-- [start:intent]
struct LogWaterIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Water"
    static let description = IntentDescription("Record a drink in My Drink.")

    @Parameter(title: "Amount (ml)", default: 250, inclusiveRange: (50, 1000))
    var milliliters: Int

    @Parameter(title: "Drink", default: .water)
    var beverage: Beverage

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$milliliters) ml of \(\.$beverage)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<DrinkEntity> & ProvidesDialog {
        let drink = WaterStore.shared.add(beverage, milliliters: milliliters)
        let total = WaterStore.shared.todayTotal
        return .result(
            value: DrinkEntity(drink),
            dialog: "Logged \(milliliters) ml. Today: \(total) of \(WaterData.dailyGoal) ml."
        )
    }
}
// --8<-- [end:intent]

// --8<-- [start:init]
extension LogWaterIntent {
    /// ใช้ตอนสร้าง intent เองในโค้ด เช่น ปุ่มใน widget
    init(milliliters: Int, beverage: Beverage = .water) {
        self.milliliters = milliliters
        self.beverage = beverage
    }
}
// --8<-- [end:init]

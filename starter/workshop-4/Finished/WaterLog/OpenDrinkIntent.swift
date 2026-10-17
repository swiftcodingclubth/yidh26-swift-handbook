import AppIntents

// Xcode 27 ใช้ OpenDrinkIntent แบบ App Schema ใน SiriAI/OpenDrinkIntent+Schema.swift แทน
// เพราะ entity หนึ่งตัวมี OpenIntent ได้ตัวเดียว
#if !compiler(>=6.4)
// --8<-- [start:open]
/// เมื่อผู้ใช้แตะ drink ใน Spotlight หรือใน Siri ระบบจะใช้ intent นี้เปิด app ไปที่ drink นั้น
struct OpenDrinkIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Drink"

    @Parameter(title: "Drink")
    var target: DrinkEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.openDrink = WaterStore.shared.drink(id: target.id)
        return .result()
    }
}
// --8<-- [end:open]
#endif

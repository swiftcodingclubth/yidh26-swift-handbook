import AppIntents

// App Schemas เป็น API ของ iOS 27: build ได้เฉพาะ Xcode 27
// บน Xcode 26 จะใช้ OpenDrinkIntent แบบธรรมดาใน OpenDrinkIntent.swift แทน
#if compiler(>=6.4)
// --8<-- [start:schema]
/// ใช้ schema .system.open ทำให้ Siri รู้ว่า intent นี้คือ "เปิดสิ่งนี้"
/// schema กำหนด title และ parameter ให้แล้ว เราเขียนแค่ target กับ perform()
@available(iOS 27.0, *)
@AppIntent(schema: .system.open)
struct OpenDrinkIntent {
    var target: DrinkEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.openDrink = WaterStore.shared.drink(id: target.id)
        return .result()
    }
}
// --8<-- [end:schema]
#endif

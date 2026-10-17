import AppIntents

// App Schemas เป็น API ของ iOS 27: build ได้เฉพาะ Xcode 27
#if compiler(>=6.4)
// --8<-- [start:search]
/// ใช้ schema .system.searchInApp ทำให้ Siri เข้าใจคำสั่งค้นหา เช่น "Search My Drink for coffee"
/// แล้วเปิด app พร้อมผลค้นหา
@available(iOS 27.0, *)
@AppIntent(schema: .system.searchInApp)
struct SearchDrinksIntent {
    var criteria: StringSearchCriteria

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.searchText = criteria.term
        return .result()
    }
}
// --8<-- [end:search]
#endif

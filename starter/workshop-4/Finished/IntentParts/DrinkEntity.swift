import AppIntents
import CoreSpotlight

// --8<-- [start:entity]
struct DrinkEntity: AppEntity, IndexedEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Drink"
    static let defaultQuery = DrinkQuery()

    let id: UUID

    // ทุก @Property คือสิ่งที่ Siri, Shortcuts และ "Use Model" มองเห็น
    @Property(title: "Drink") var beverage: Beverage
    @Property(title: "Amount (ml)") var milliliters: Int
    @Property(title: "Time") var date: Date

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(beverage.name) \(milliliters) ml",
            subtitle: "\(date.formatted(date: .abbreviated, time: .shortened))",
            image: .init(systemName: beverage.symbol)
        )
    }

    init(_ drink: Drink) {
        id = drink.id
        beverage = drink.beverage
        milliliters = drink.milliliters
        date = drink.date
    }
}
// --8<-- [end:entity]

// --8<-- [start:query]
struct DrinkQuery: EntityStringQuery {
    /// ระบบเก็บแค่ id ไว้ แล้วขอ entity ตัวเต็มจาก app ทีหลัง
    func entities(for identifiers: [UUID]) async throws -> [DrinkEntity] {
        await MainActor.run {
            identifiers.compactMap { WaterStore.shared.drink(id: $0) }.map(DrinkEntity.init)
        }
    }

    /// รายการที่แสดงให้เลือกใน Shortcuts
    func suggestedEntities() async throws -> [DrinkEntity] {
        await MainActor.run { WaterStore.shared.todayDrinks.map(DrinkEntity.init) }
    }

    /// ค้นจากข้อความที่ผู้ใช้พิมพ์หรือพูด เช่น "coffee"
    func entities(matching string: String) async throws -> [DrinkEntity] {
        await MainActor.run {
            WaterStore.shared.drinks
                .filter { $0.beverage.name.localizedStandardContains(string) }
                .map(DrinkEntity.init)
        }
    }
}
// --8<-- [end:query]

// --8<-- [start:spotlight]
/// ส่ง entity ให้ Spotlight ทุกครั้งที่ข้อมูลเปลี่ยน ระบบจะค้นเจอทั้งใน Spotlight และ Siri
nonisolated enum SpotlightIndex {
    static func add(_ drink: Drink) {
        Task { try? await CSSearchableIndex.default().indexAppEntities([DrinkEntity(drink)]) }
    }

    static func remove(_ drink: Drink) {
        Task {
            try? await CSSearchableIndex.default()
                .deleteAppEntities(identifiedBy: [drink.id], ofType: DrinkEntity.self)
        }
    }
}
// --8<-- [end:spotlight]

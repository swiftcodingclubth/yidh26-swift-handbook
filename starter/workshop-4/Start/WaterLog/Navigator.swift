import Observation

/// เก็บว่าตอนนี้ต้องเปิดหน้าไหน OpenDrinkIntent ใช้เพื่อพาผู้ใช้ไปที่รายการที่แตะจาก Spotlight หรือ Siri
@MainActor @Observable
final class Navigator {
    static let shared = Navigator()
    var openDrink: Drink?
    /// คำค้นจาก SearchDrinksIntent (Siri) หรือช่องค้นหาใน app
    var searchText = ""
}

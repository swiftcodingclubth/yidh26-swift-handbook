import Foundation

/// ชนิดเครื่องดื่ม เป็น enum ธรรมดาของ app (Code-along 3 จะทำให้ระบบรู้จักด้วย AppEnum)
nonisolated enum Beverage: String, Codable, CaseIterable, Sendable {
    case water, tea, coffee, milk, juice

    var name: String {
        switch self {
        case .water: "Water"
        case .tea: "Tea"
        case .coffee: "Coffee"
        case .milk: "Milk"
        case .juice: "Juice"
        }
    }

    var symbol: String {
        switch self {
        case .water: "drop.fill"
        case .tea: "leaf.fill"
        case .coffee: "cup.and.saucer.fill"
        case .milk: "mug.fill"
        case .juice: "takeoutbag.and.cup.and.straw.fill"
        }
    }
}

/// หนึ่งครั้งที่ดื่ม นี่คือ data model ของ app ซึ่งยังเป็น source of truth
nonisolated struct Drink: Codable, Identifiable, Hashable, Sendable {
    var id = UUID()
    var beverage: Beverage
    var milliliters: Int
    var date = Date()
}

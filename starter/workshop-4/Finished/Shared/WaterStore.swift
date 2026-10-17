import Foundation
import Observation
import WidgetKit

/// อ่าน/เขียนข้อมูลใน App Group ที่ app และ widget extension ใช้ร่วมกัน
/// ไม่ผูกกับ MainActor จึงเรียกจาก widget timeline ได้
nonisolated enum WaterData {
    static let dailyGoal = 2000
    private static let key = "drinks"

    /// App Group ID มาจาก build setting WATERLOG_APP_GROUP ผ่าน Info.plist
    /// ถ้าหาไม่เจอ (ยังไม่ได้ตั้ง App Group) จะใช้ UserDefaults ปกติ: app ทำงานได้ แต่ widget จะไม่เห็นข้อมูล
    static var defaults: UserDefaults {
        let group = Bundle.main.object(forInfoDictionaryKey: "WaterLogAppGroup") as? String
        return group.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }

    static func load() -> [Drink] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Drink].self, from: data)) ?? []
    }

    static func save(_ drinks: [Drink]) {
        defaults.set(try? JSONEncoder().encode(drinks), forKey: key)
    }

    static func todayTotal(in drinks: [Drink] = load()) -> Int {
        drinks.filter { Calendar.current.isDateInToday($0.date) }.reduce(0) { $0 + $1.milliliters }
    }
}

/// ข้อมูลที่หน้าจอของ app ใช้ ทุก action ทั้งจากปุ่มใน app, Siri, Shortcuts และ widget มาจบที่นี่
@MainActor @Observable
final class WaterStore {
    static let shared = WaterStore()

    private(set) var drinks: [Drink] = []

    init() { reload() }

    var todayDrinks: [Drink] {
        drinks.filter { Calendar.current.isDateInToday($0.date) }.sorted { $0.date > $1.date }
    }

    var todayTotal: Int { WaterData.todayTotal(in: drinks) }

    /// อ่านใหม่จาก App Group เพราะ widget อาจเขียนข้อมูลไว้ตอนที่ app ไม่ได้เปิดอยู่
    func reload() {
        drinks = WaterData.load()
    }

    @discardableResult
    func add(_ beverage: Beverage = .water, milliliters: Int) -> Drink {
        reload()
        let drink = Drink(beverage: beverage, milliliters: milliliters)
        drinks.append(drink)
        save()
        SpotlightIndex.add(drink)
        return drink
    }

    func delete(_ drink: Drink) {
        reload()
        drinks.removeAll { $0.id == drink.id }
        save()
        SpotlightIndex.remove(drink)
    }

    func drink(id: UUID) -> Drink? {
        reload()
        return drinks.first { $0.id == id }
    }

    private func save() {
        WaterData.save(drinks)
        // บอก widget และ control ให้วาดใหม่ทันที
        WidgetCenter.shared.reloadAllTimelines()
        ControlCenter.shared.reloadAllControls()
    }
}

import XCTest

// AppIntentsTesting มีเฉพาะ iOS 27 SDK (Xcode 27) บน Xcode 26 ไฟล์นี้จะว่างและ build ผ่าน
#if canImport(AppIntentsTesting)
import AppIntentsTesting

@available(iOS 27.0, *)
final class WaterLogIntentTests: XCTestCase {
    // Bundle ID ของ test คือ "<bundle ID ของ app>.uitests" จึงตัดท้ายออกก็ได้ bundle ID ของ app
    var definitions: IntentDefinitions {
        let testBundleID = Bundle(for: Self.self).bundleIdentifier ?? ""
        return IntentDefinitions(bundleIdentifier: testBundleID.replacingOccurrences(of: ".uitests", with: ""))
    }

    // เปิด app หนึ่งครั้งก่อน ระบบจึงรู้จัก intent ของ app
    override func setUp() async throws {
        await XCUIApplication().launch()
    }

    // --8<-- [start:test]
    func testLogWaterReturnsDrink() async throws {
        let logWater = definitions.intents["LogWaterIntent"]

        // run intent ผ่านระบบจริงแบบเดียวกับ Siri และ Shortcuts
        let result = try await logWater.makeIntent(milliliters: 300, beverage: "tea").run()

        XCTAssertEqual(try result.value.milliliters, 300)
    }

    func testFindDrinkByName() async throws {
        _ = try await definitions.intents["LogWaterIntent"].makeIntent(milliliters: 200, beverage: "coffee").run()

        let drinks = try await definitions.entities["DrinkEntity"].entities(matching: "Coffee")

        XCTAssertFalse(drinks.isEmpty)
    }
    // --8<-- [end:test]
}
#endif

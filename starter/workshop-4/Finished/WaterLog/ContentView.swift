import AppIntents
import SwiftUI

struct ContentView: View {
    @State private var store = WaterStore.shared
    @State private var navigator = Navigator.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if navigator.searchText.isEmpty {
                        TodayCard(total: store.todayTotal, goal: WaterData.dailyGoal, count: store.todayDrinks.count)
                        QuickAddGrid()
                        DrinkList(title: "Today", drinks: store.todayDrinks)
                    } else {
                        DrinkList(title: "Results", drinks: searchResults)
                    }
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .background(Backdrop())
            .navigationTitle("My Drink")
            // ช่องค้นหาเดียวกับที่ SearchDrinksIntent ใส่คำค้นให้เมื่อสั่ง Siri
            .searchable(text: $navigator.searchText, prompt: "Search drinks")
            .sheet(item: $navigator.openDrink) { drink in
                DrinkDetail(drinkID: drink.id)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // widget อาจบันทึกข้อมูลไว้ตอนที่ app อยู่เบื้องหลัง
            if phase == .active { store.reload() }
        }
    }

    private var searchResults: [Drink] {
        store.drinks
            .filter { $0.beverage.name.localizedStandardContains(navigator.searchText) }
            .sorted { $0.date > $1.date }
    }
}

/// พื้นหลังโทนน้ำ ให้กระจก (Liquid Glass) มีสีให้หักเห
struct Backdrop: View {
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.6, 0.45], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
            colors: [.cyan.opacity(0.45), .blue.opacity(0.3), .indigo.opacity(0.35),
                     .teal.opacity(0.3), .white.opacity(0.15), .cyan.opacity(0.25),
                     .blue.opacity(0.3), .mint.opacity(0.25), .indigo.opacity(0.3)]
        )
        .ignoresSafeArea()
    }
}

/// วงแหวนของวันนี้: ดื่มไปเท่าไหร่ เหลืออีกเท่าไหร่
struct TodayCard: View {
    let total: Int
    let goal: Int
    let count: Int

    var body: some View {
        HStack(spacing: 24) {
            ZStack {
                ProgressRing(progress: Double(total) / Double(goal))
                Text(Double(total) / Double(goal), format: .percent.precision(.fractionLength(0)))
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .contentTransition(.numericText())
            }
            .frame(width: 120, height: 120)

            VStack(alignment: .leading, spacing: 4) {
                Text("Today").font(.subheadline.bold()).foregroundStyle(.secondary)
                Text("\(total.formatted()) ml")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .contentTransition(.numericText())
                Text("of \(goal.formatted()) ml · \(count) drinks")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if total >= goal {
                    Label("Goal reached", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                } else {
                    Text("\((goal - total).formatted()) ml to go")
                        .font(.subheadline.bold())
                        .foregroundStyle(.blue)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(24)
        .glassEffect(.regular, in: .rect(cornerRadius: 32))
        .animation(.spring(duration: 0.5), value: total)
    }
}

/// ปุ่มเพิ่มเครื่องดื่มด่วน กดครั้งเดียวบันทึกเลย
struct QuickAddGrid: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick add").font(.title3.bold())
            GlassEffectContainer(spacing: 12) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                    // --8<-- [start:app-button]
                    // ปุ่มใน app ก็เรียก intent ตัวเดียวกับ Siri และ widget ได้
                    Button(intent: LogWaterIntent(milliliters: 250)) {
                        QuickAddLabel(beverage: .water, milliliters: 250)
                    }
                    // --8<-- [end:app-button]
                    Button(intent: LogWaterIntent(milliliters: 500)) {
                        QuickAddLabel(beverage: .water, milliliters: 500)
                    }
                    Button(intent: LogWaterIntent(milliliters: 250, beverage: .tea)) {
                        QuickAddLabel(beverage: .tea, milliliters: 250)
                    }
                    Button(intent: LogWaterIntent(milliliters: 200, beverage: .coffee)) {
                        QuickAddLabel(beverage: .coffee, milliliters: 200)
                    }
                    Button(intent: LogWaterIntent(milliliters: 250, beverage: .milk)) {
                        QuickAddLabel(beverage: .milk, milliliters: 250)
                    }
                    Button(intent: LogWaterIntent(milliliters: 300, beverage: .juice)) {
                        QuickAddLabel(beverage: .juice, milliliters: 300)
                    }
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.roundedRectangle(radius: 24))
            }
        }
    }
}

struct QuickAddLabel: View {
    let beverage: Beverage
    let milliliters: Int

    var body: some View {
        VStack(spacing: 6) {
            BeverageIcon(beverage: beverage, size: 44)
            Text(beverage.name).font(.subheadline.bold())
            Text("\(milliliters) ml").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
}

struct DrinkList: View {
    let title: String
    let drinks: [Drink]
    @State private var store = WaterStore.shared
    @State private var navigator = Navigator.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title3.bold())
            if drinks.isEmpty {
                ContentUnavailableView(
                    "No drinks yet",
                    systemImage: "drop",
                    description: Text("Tap a button above, or try Shortcuts, Spotlight or Siri.")
                )
                .glassEffect(.regular, in: .rect(cornerRadius: 26))
            }
            GlassEffectContainer(spacing: 10) {
                VStack(spacing: 10) {
                    ForEach(drinks) { drink in
                        DrinkCard(drink: drink)
                            .onTapGesture { navigator.openDrink = drink }
                            .contextMenu {
                                Button("Delete", systemImage: "trash", role: .destructive) { store.delete(drink) }
                            }
                            // --8<-- [start:annotate]
                            // บอกระบบว่าการ์ดนี้คือ drink ตัวไหน Siri จึงเข้าใจ "open the second one"
                            .appEntityIdentifier(EntityIdentifier(for: DrinkEntity.self, identifier: drink.id))
                            // --8<-- [end:annotate]
                    }
                }
            }
        }
        .animation(.default, value: drinks)
    }
}

struct DrinkCard: View {
    let drink: Drink

    var body: some View {
        HStack(spacing: 14) {
            BeverageIcon(beverage: drink.beverage, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(drink.beverage.name).font(.headline)
                Text(drink.date, format: .dateTime.hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(drink.milliliters) ml")
                .font(.system(.headline, design: .rounded))
                .monospacedDigit()
        }
        .padding(14)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
        .contentShape(.rect(cornerRadius: 22))
    }
}

struct DrinkDetail: View {
    let drinkID: UUID
    @State private var store = WaterStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if let drink = store.drink(id: drinkID) {
            VStack(spacing: 16) {
                BeverageIcon(beverage: drink.beverage, size: 96)
                Text("\(drink.beverage.name) \(drink.milliliters) ml")
                    .font(.system(.title, design: .rounded, weight: .bold))
                Text(drink.date.formatted(date: .complete, time: .shortened))
                    .foregroundStyle(.secondary)
                Button("Delete Drink", systemImage: "trash", role: .destructive) {
                    store.delete(drink)
                    dismiss()
                }
                .buttonStyle(.glass)
                .padding(.top, 8)
            }
            .padding(32)
            .presentationDetents([.medium])
            // --8<-- [start:detail]
            // หน้านี้แสดง drink ตัวเดียวเป็นหลัก: บอกระบบผ่าน user activity
            // Siri จึงรู้ว่า "this" หมายถึงแก้วนี้
            .userActivity("th.yidh26.waterlog.view-drink") { activity in
                activity.title = "\(drink.beverage.name) \(drink.milliliters) ml"
                activity.appEntityIdentifier = EntityIdentifier(for: DrinkEntity.self, identifier: drink.id)
            }
            // --8<-- [end:detail]
        } else {
            ContentUnavailableView("Drink deleted", systemImage: "trash")
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    ContentView()
}

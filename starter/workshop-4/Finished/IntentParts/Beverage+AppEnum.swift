import AppIntents

// --8<-- [start:enum]
extension Beverage: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Drink"

    static let caseDisplayRepresentations: [Beverage: DisplayRepresentation] = [
        .water: DisplayRepresentation(title: "Water", image: .init(systemName: "drop.fill")),
        .tea: DisplayRepresentation(title: "Tea", image: .init(systemName: "leaf.fill")),
        .coffee: DisplayRepresentation(title: "Coffee", image: .init(systemName: "cup.and.saucer.fill")),
        .milk: DisplayRepresentation(title: "Milk", image: .init(systemName: "mug.fill")),
        .juice: DisplayRepresentation(title: "Juice", image: .init(systemName: "takeoutbag.and.cup.and.straw.fill")),
    ]
}
// --8<-- [end:enum]

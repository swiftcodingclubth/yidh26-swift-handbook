import SwiftUI

@main
struct MotionRecorderApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RecordView()
            }
        }
    }
}

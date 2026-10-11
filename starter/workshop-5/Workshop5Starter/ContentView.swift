import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Scan", systemImage: "text.viewfinder") { ScanTab() }
            Tab("Read", systemImage: "doc.text.magnifyingglass") { ReadTab() }
            Tab("Hand", systemImage: "hand.raised") { HandTab() }
            Tab("Game", systemImage: "gamecontroller") { GameTab() }
            Tab("AI", systemImage: "sparkles") { AITab() }
            Tab("Languages", systemImage: "globe") { LanguagesTab() }
        }
    }
}

#Preview {
    ContentView()
}

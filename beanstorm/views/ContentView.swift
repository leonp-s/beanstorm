import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BrewView()
                .tabItem {
                    Label(
                        "Brew",
                        systemImage: "play.circle"
                    )
                }
            ProfilesView()
                .tabItem {
                    Label(
                        "Profiles",
                        systemImage: "stopwatch"
                    )
                }
            SettingsView()
                .tabItem {
                    Label(
                        "Settings",
                        systemImage: "gearshape"
                    )
                }
        }
    }
}

#Preview {
    ContentView()
}

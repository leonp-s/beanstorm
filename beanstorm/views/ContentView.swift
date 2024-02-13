import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var beanstormBLE: BeanstormBLEModel

    var body: some View {
        TabView {
            Group {
                if(beanstormBLE.isConnected) {
                    BrewView(
                        peripheralModel: .init(dataService: beanstormBLE.service.connectedPeripheral!)
                    )
                } else {
                    DeviceConnectivity()
                }
            }
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
        .deviceConnectivityScanningRoot()
    }
}

#Preview {
    ContentView()
        .environmentObject(BeanstormBLEModel())
}

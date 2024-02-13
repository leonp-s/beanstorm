import SwiftUI
import SwiftData

@main
struct BeanstormApp: App {
    @StateObject private var beanstormBLE = BeanstormBLEModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(beanstormBLE)
        .modelContainer(for: BrewProfile.self)
    }
}
